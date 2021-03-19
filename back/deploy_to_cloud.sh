export JAVA_HOME=$(/usr/libexec/java_home -v 11)

# build jar
# TODO: could be replaced with 2-step docker build (cf. cloud run quick start for java/spring)
./gradlew build

# build docker image then upload it to google container registry
# this command should replace the two following (but it fails, to check) gcloud builds submit --tag gcr.io/ibo-speak/back
docker build . --tag gcr.io/realingo/back
docker push gcr.io/realingo/back

# deploy image from container registry to google cloud run
gcloud run deploy back --image gcr.io/realingo/back --platform managed --memory 1G --allow-unauthenticated --max-instances 1
