export JAVA_HOME=$(/usr/libexec/java_home -v 11)
./gradlew build
docker build
