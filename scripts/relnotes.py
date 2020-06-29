# Generates Simple Release Notes for Kiali given a release version and Sprint Project.
# The output can then be clipped into kiali.io/content/news/release-notes.adoc as the
# base for that version's release notes.
#
# Requires:
# - a github oauth token with public_repo and read:org scopes for kiali
# - python (tested with 2.7.17)
#
# usage: $ python relnotes <version: vX.Y.Z> <projectNumber: int> <githubOauthToken>
#

import re
import requests
import sys

if len(sys.argv) != 4:
    print 'usage: $ python relnotes.py <version: X.Y.Z> <projectNumber: int> <githubOauthToken>'
    exit

version = sys.argv[1]
projectNumber = sys.argv[2]
headers = {"Authorization": "bearer " + sys.argv[3]}

# The GraphQL query as a multi-line string.       
query = """
{
  organization(login: "kiali")
  {
    name
    project(number: $projectNumber) {
      body
      name
      columns(last: 1) {
        nodes {
          cards {
            nodes {
              content {
                __typename
                ... on Issue {
                  title
                  url
                  closedAt
                  labels(first: 10) {
                    nodes {
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

def run_query(query):
    query = query.replace("$projectNumber", projectNumber)
    request = requests.post('https://api.github.com/graphql', json={"query": query}, headers=headers)
    if request.status_code == 200:
        return request.json()
    else:
        raise Exception("Query failed to run by returning code of {}. {}".format(request.status_code, query))
        

result = run_query(query) # Execute the query
project = result["data"]["organization"]["project"]
projectName = project["name"]
releaseDatePattern = re.compile('^.*Ends:\s*([^\n]*).*$', re.DOTALL)
releaseDate = releaseDatePattern.match(project["body"])

print("\nRelease Notes for {}, Project: {}".format(version, projectName))
print("------------Clip Below This Line----------------")
print("== {}".format(version))
print("Sprint Release: {}".format([releaseDate.group(1),"Unknown"][releaseDate is None]))

print("\nFeatures:\n")

for card in project["columns"]["nodes"][0]["cards"]["nodes"]:
    if card["content"]["__typename"] == "PullRequest":
        continue
    issue = card["content"]
    labelNames = list(map((lambda x: x["name"]), issue["labels"]["nodes"]))
    if not "bug" in labelNames:
        title = issue["title"].replace("[", "(").replace("]", ")")
        print("* {}[{}]".format(issue["url"], title))

print("\nFixes:\n")

for card in project["columns"]["nodes"][0]["cards"]["nodes"]:
    if card["content"]["__typename"] == "PullRequest":
        continue
    issue = card["content"]
    labelNames = list(map((lambda x: x["name"]), issue["labels"]["nodes"]))
    if "bug" in labelNames:
        title = issue["title"].replace("[", "(").replace("]", ")")
        print("* {}[{}]".format(issue["url"], title))

