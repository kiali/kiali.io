# An example to get the remaining rate limit using the Github GraphQL API.

import requests
import sys

if len(sys.argv) != 3:
    print 'usage: $ python relnotes <projectNumber> <gh oauth token>'
    exit

projectNumber = sys.argv[1]
headers = {"Authorization": "bearer " + sys.argv[2]}

# The GraphQL query as a multi-line string.       
query = """
{
  organization(login: "kiali")
  {
    name
    project(number: $projectNumber) {
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
                  labels {
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
print("Project: {}".format(projectName))
for card in project["columns"]["nodes"][0]["cards"]["nodes"]:
    if card["content"]["__typename"] == "PullRequest":
        continue
    issue = card["content"]
    print("Title: {}".format(issue["title"]))
    print("URL: {}".format(issue["url"]))

