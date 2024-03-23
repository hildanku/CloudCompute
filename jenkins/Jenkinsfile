node {
    stage('Build') {
        docker.image('python:alpine3.19').inside {
            sh 'python -m py_compile sources/add2vals.py sources/calc.py'
            stash(name: 'compiled-results', includes: 'sources/*.py*')
        }
    }
    stage('Test') {
        docker.image('qnib/pytest').inside {
            sh 'py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py'
            junit 'test-reports/results.xml'
        }
    }
    stage('Manual Approval') {
        input 'Lanjutkan ke tahap Deploy?'
        echo 'Lanjut ke tahap Deployment'
    }
    stage('Deploy') {
        unstash(name: 'compiled-results')
        sh "docker run --rm -v '${pwd()}/sources:/src' cdrx/pyinstaller-linux:python2 'pyinstaller -F add2vals.py'"
        archiveArtifacts "sources/dist/add2vals"
        sleep time: 60 , unit: 'SECONDS'
        } 
}
