/*
 * This pipeline supports only `minor` releases. Don't run it on `major`, `patch`,
 * `snapshot`, nor `edge` releases.
 *
 * The Jenkins job should be configured with the following properties:
 *
 * - Disable concurrent builds
 * - Parameters (all must be trimmed; all are strings):
 *   - SITE_REPO
 *      defaultValue: kiali/kiali.io
 *      description: The GitHub repo of the website sources, in owner/repo format.
 *   - SITE_RELEASING_BRANCH
 *      defaultValue: refs/heads/staging
 *      description: Branch of the website to checkout and run the release. This is only
 *        for testing purposes. In "production" it should be always "refs/heads/staging".
 */

def bumpVersion(String versionType, String currentVersion) {
  def split = currentVersion.split('\\.')
    switch (versionType){
      case "patch":
        split[2]=1+Integer.parseInt(split[2])
          break
      case "minor":
          split[1]=1+Integer.parseInt(split[1])
          split[2]=0
            break;
      case "major":
          split[0]=1+Integer.parseInt(split[0])
          split[1]=0
          split[2]=0
            break;
    }
  return split.join('.')
}

node('kiali-build && fedora') {
  def siteGitUri = "git@github.com:${params.SITE_REPO}.git"

  try {
    stage('Checkout code') {
      checkout([
          $class: 'GitSCM',
          branches: [[name: params.SITE_RELEASING_BRANCH]],
          doGenerateSubmoduleConfigurations: false,
          extensions: [
            [$class: 'LocalBranch', localBranch: '**']
          ],
          submoduleCfg: [],
          userRemoteConfigs: [[
          credentialsId: 'kiali-bot-gh-ssh',
          url: siteGitUri]]
      ])

        sh "git config user.email 'kiali-dev@googlegroups.com'"
        sh "git config user.name 'kiali-bot'"
    }

    stage('Release website') {
      withCredentials([string(credentialsId: 'kiali-bot-gh-token', variable: 'GH_TOKEN')]) {
        sshagent(['kiali-bot-gh-ssh']) {
          def lastReleasedVersion = sh(
              returnStdout: true,
              script: "awk '/## NEXT/,/url/' config.toml | grep -o '\\\"v.*\\\"' | tr -d '\"'").trim()
          lastReleasedVersion = lastReleasedVersion + ".0"

          def releasingVersion = bumpVersion("minor", lastReleasedVersion)
          echo "Resolved current website version: ${releasingVersion}"
          sh "./scripts/release.sh -cv ${releasingVersion} -rn origin -gd true"
        }
      }
    }
  } finally {
    cleanWs()
  }
}
