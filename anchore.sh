ANCHORE_CLI_URL: "http://anchore.example.com:8228/v1"
ANCHORE_CLI_USER: "admin"
ANCHORE_CLI_PASS: "foobar"
ANCHORE_CLI_SSL_VERIFY: "false"
ANCHORE_SCAN_IMAGE: docker.io/library/debian
ANCHORE_RETRIES: 12
ANCHORE_FAIL_ON_POLICY: "false"
echo "Adding image to Anchore engine at ${ANCHORE_CLI_URL}"
anchore-cli image add ${ANCHORE_SCAN_IMAGE}
echo "Waiting for analysis to complete"
counter=0
while (! (anchore-cli image get ${ANCHORE_SCAN_IMAGE} | grep Status\:\ analyzed) > /dev/null) ; do echo -n "." ; sleep 10 ; if [ $counter -eq ${ANCHORE_RETRIES} ] ; then echo " Timeout waiting for analysis" ; exit 1 ; fi ; counter=$(($counter+1)) ; done
echo "Analysis complete and Producing reports"
anchore-cli --json image content ${ANCHORE_SCAN_IMAGE} os > image-packages.json
anchore-cli --json image content ${ANCHORE_SCAN_IMAGE} npm > image-npm.json
anchore-cli --json image content ${ANCHORE_SCAN_IMAGE} gem > image-gem.json
anchore-cli --json image content ${ANCHORE_SCAN_IMAGE} python > image-python.json
anchore-cli --json image content ${ANCHORE_SCAN_IMAGE} java > image-java.json
anchore-cli --json image vuln ${ANCHORE_SCAN_IMAGE} os > image-vulnerabilities.json
anchore-cli --json image get ${ANCHORE_SCAN_IMAGE} > image-details.json
anchore-cli --json evaluate check ${ANCHORE_SCAN_IMAGE} --detail > image-policy.json || true
if [ "${ANCHORE_FAIL_ON_POLICY}" == "true" ] ; then anchore-cli evaluate check ${ANCHORE_SCAN_IMAGE}  ; fi 
