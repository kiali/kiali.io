/*
 * This pipeline supports only `minor` and `major` releases. Don't run it on `patch`,
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
 *      defaultValue: refs/heads/master
 *      description: Branch of the website to checkout and run the release
 */

def bumpVersion(String versionType, String currentVersion) {
  def split = currentVersion.split('\\.')
    switch (versionType){
      case "patch":
        split[2]=1+Integer.parseInt(split[2])
          break
      case "minor":
          split[1]=1+Integer.parseInt(split[1])
            break;
      case "major":
          split[0]=1+Integer.parseInt(split[0])
            break;
    }
  return split.join('.')
}

node('kiali-build && fedora') {
  def siteMakefile = 'Makefile.site.jenkins'
  def siteGitUri = "git@github.com:${params.SITE_REPO}.git"
  def mainBranch = 'master'

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
          def releasingVersion = sh(
              returnStdout: true,
              script: "sed -rn 's/^VERSION \\?= v(.*)/\\1/p' Makefile").trim()
          def nextVersion = bumpVersion("minor", releasingVersion)
          echo "Will build version: ${releasingVersion}"
          sh "./scripts/build-archive.sh v${releasingVersion}"

          echo "Prepare for next version: ${nextVersion}"
          sh "sed -i -r 's/^VERSION \\?= v.*/VERSION \\?= v${nextVersion}/' Makefile"
          sh "git add -A && git commit -m \"Release v${releasingVersion}\""
          sh "git push origin HEAD:${mainBranch} && git push origin HEAD:refs/tags/v${releasingVersion}"
        }
      }
    }
  } finally {
    cleanWs()
  }
}
