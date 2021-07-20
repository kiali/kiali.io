#!/bin/python

# Looks for backports since a previous patch release.
#
# Requires:
# - a github oauth token with public_repo and read:org scopes for kiali
# - python (tested with 3.8.7)
#
# usage: > ./backports.py <releaseBranch: string (e.g. v1.36)> <sincePatch: int (e.g. 1)> <numProjects: int (e.g. 3 for PRs in last 3 projects)> <githubOauthToken>
#

import re
import requests
import sys

if len(sys.argv) != 5:
    print( '\nUSAGE: > ./backports.py <releaseBranch: string (e.g. v1.36)> <sincePatch: int (e.g. 1)> <numProjects: int (e.g. 3 for PRs in last 3 projects)> <githubOauthToken>' )
    sys.exit()

releaseBranch = sys.argv[1]
sincePatch = sys.argv[2]
numProjects = sys.argv[3]
headers = {"Authorization": "bearer " + sys.argv[4]}
sinceVersion = "{}.{}".format(releaseBranch, sincePatch)

# GraphQL queries as a multi-line string.
sinceQuery = """
{
  organization(login: "kiali") {
    repository(name: "kiali") {
      release(tagName: "$sinceVersion") {
        createdAt
      }
    }
  }
}
"""

query = """
{
  organization(login: "kiali")
  {
    name
    projects(last: $numProjects) {
      nodes {
        body
        name
        columns(last: 1) {
          nodes {
            cards {
              nodes {
                content {
                  __typename
                  ... on PullRequest {
                    title
                    url
                    closedAt
                    baseRef {
                      name
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
"""

def get_since_time(sinceQuery):
    sinceQuery = sinceQuery.replace("$sinceVersion", sinceVersion)
    request = requests.post('https://api.github.com/graphql', json={"query": sinceQuery}, headers=headers)
    if request.status_code == 200:
        return request.json()["data"]["organization"]["repository"]["release"]["createdAt"]
    else:
        raise Exception("SinceeQuery failed to run by returning code of {}. {}".format(request.status_code, query))

def run_query(query):
    query = query.replace("$numProjects", numProjects)
    request = requests.post('https://api.github.com/graphql', json={"query": query}, headers=headers)
    if request.status_code == 200:
        return request.json()
    else:
        raise Exception("Query failed to run by returning code of {}. {}".format(request.status_code, query))
        

sinceTime = get_since_time(sinceQuery)
result = run_query(query) # Execute the query
projects = result["data"]["organization"]["projects"]
backports = []

print("\nBackports since {} ({}), looking in last {} projects:".format(sinceVersion, sinceTime, numProjects))
print("-----------------------------------")

for project in projects["nodes"]:
    for card in project["columns"]["nodes"][0]["cards"]["nodes"]:
        if card["content"]["__typename"] != "PullRequest":
            continue
        pr = card["content"]        
        baseRef = pr["baseRef"]["name"]
        closedAt = pr["closedAt"]
        if baseRef == releaseBranch and closedAt > sinceTime:
            title = pr["title"].replace("[", "(").replace("]", ")")
            backports.append("{} [{}] {} ".format(pr["url"], title, closedAt))

backports.sort()
for backport in backports:
    print("{}".format(backport))

