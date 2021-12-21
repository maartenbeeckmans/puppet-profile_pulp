#!/bin/bash
#
# Script used for uploading an rpm to a pulpcore repository
#
# Usage
#
# $ ./upload_rpm.sh --repo repository-to-upload --package package-name.rpm
#

# Parsing parameters
while true; do
        case "$1" in
                -r | --repo | --repository ) repository="$2"; shift;;
                -p | --package ) package_name="$2"; shift;;
                -- ) break;;
                * ) break;;
        esac
        shift
done

[ -z "$repository" ] && read -p 'Repository name: ' repository
[ -z "$package_name" ] && read -p 'Package name: ' package_name

echo "###################################"
echo "# Uploading content               #"
echo "###################################"
package_href=$(pulp rpm content upload --relative-path $package_name --file $package_name 2> /tmp/upload-error | jq .pulp_href | xargs)

if [ -z "$package_href" ]; then
        cat /tmp/upload-error
        # Checking if error is 'Artifact already exists',
        # if yes, continue and upload existing artifact
        # if no, exit script
        grep 'Artifact already exists' /tmp/upload-error || exit 1
        echo 'Package already exists as artifact in pulpcore, adding existing artifact to repository'
        package_id=$(grep -oE 'pkgId=[0-9a-f]{64},' /tmp/upload-error | sed -E 's/(pkgId=|,)//g')
        package_href=$(pulp rpm content show --sha256 $package_id | jq .pulp_href | xargs)
fi

echo "###################################"
echo "# Showing package information     #"
echo "###################################"
pulp rpm content show --href $package_href

echo "###################################"
echo "# Adding content to repository    #"
echo "###################################"
pulp rpm repository content add --repository $repository --package-href $package_href

echo "Package ${package_name} has been uploaded to ${repository}"

