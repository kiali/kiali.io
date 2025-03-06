import os
import json
from github import Github

# Authentication is defined via github.Auth
from github import Auth

REPOS = ["kiali", "kiali-operator", "openshift-servicemesh-plugin"]


class KialiApi:
    def __init__(self):
        TOKEN = os.getenv("KIALI_API_TOKEN")
        auth = Auth.Token(TOKEN)
        self.client = Github(auth=auth)
        self.organization = "kiali"
        with open('./content/en/community/data/metrics.json') as f:
            self.data = json.load(f)
    def generate(self):        
        self.getRepositories()
        self.write_json()        
    def getRepositories(self):
        org = self.client.get_organization("kiali")
        for repoName in REPOS:
            repo = org.get_repo(repoName)
            if "repositories" not in self.data:
                self.data["repositories"] = {}
            if repoName not in self.data["repositories"]:
                self.generate_initial_data(repoName)
            self.data["repositories"][repoName]["language"] = repo.get_languages()
            keyDate = repo.updated_at.strftime("%Y-%m-%d")
            

            if keyDate not in self.data["repositories"][repoName]["metrics"]:
                self.data["repositories"][repoName]["metrics"][keyDate] = {
                    "forks": repo.forks_count,
                    "issues": repo.open_issues_count,
                    "stars": repo.stargazers_count,
                    "size": repo.size
                }        
    def generate_initial_data(self, repoName):
        repo = self.client.get_organization("kiali").get_repo(repoName)
        self.data["repositories"][repoName] = {
            "license": repo.get_license().license.name,
            "description": repo.description,
            "url": repo.html_url,
            "created": repo.created_at.strftime("%Y-%m-%d"),
            "topics": repo.topics,
            "metrics": {}
        }
    def write_json(self):
        with open('./content/en/community/data/metrics.json', 'w') as f:
            json.dump(self.data, f, indent=4)   
    def __exit__(self):
        if not self.client.closed:
            self.client.close()

client = KialiApi()
client.generate()