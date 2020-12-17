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
 */


node('kiali-build && fedora') {
  def siteMakefile = 'Makefile.site.jenkins'
  def siteReleasingBranch = 'refs/heads/master'
  def siteGitUri = "git@github.com:${params.SITE_REPO}.git"

  try {
    stage('Checkout code') {
      checkout([
          $class: 'GitSCM',
          branches: [[name: siteReleasingBranch]],
          doGenerateSubmoduleConfigurations: false,
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
          withEnv(["SHOULD_RELEASE_SITE=y"]) {
            sh "make -f ${siteMakefile} website-build-archive"
          }
        }
      }
    }
  } finally {
    cleanWs()
  }
}
