# An example to get the remaining rate limit using the Github GraphQL API.

import requests

headers = {"Authorization": "bearer a0ce00818792d667da28943349e983286beb18ee"}


def run_query(query): # A simple function to use requests.post to make the API call. Note the json= section.
    request = requests.post('https://api.github.com/graphql', json={'query': query}, headers=headers)
    if request.status_code == 200:
        return request.json()
    else:
        raise Exception("Query failed to run by returning code of {}. {}".format(request.status_code, query))

        
# The GraphQL query (with a few aditional bits included) itself defined as a multi-line string.       
query = """
{
  organization(login: "kiali")
  {
    name
    project(number: 12) {
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

