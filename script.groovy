def build() {
    echo "bulding the app .."
}


def test() {
    echo "testing the app version ${params.VERSION}"
}


def deploy() {
    echo "deploying the app to ${ENV} enviroment"
}


return this