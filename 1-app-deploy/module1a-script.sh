##### Run module1a-script
##### Then manually create Amplify Console app
##### Run module1b-script

##############Module 1a-app-deploy

## Create the repository
aws codecommit create-repository --repository-name theme-park-frontend

## Clone the frontend code base

git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true
mkdir ~/environment/theme-park-frontend
cd ~/environment/theme-park-frontend
wget https://innovator-island.s3.us-west-2.amazonaws.com/front-end/theme-park-frontend-202310.zip
unzip theme-park-frontend-202310.zip

## Push to CodeCommit
git init -b main
git add .
git commit -am "First commit"

## Push to CodeCommit
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 120")
AWS_REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/')
git push --set-upstream https://git-codecommit.$AWS_REGION.amazonaws.com/v1/repos/theme-park-frontend main

##Deploy AWS Amplify Role
accountId=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .accountId)
s3_deploy_bucket="theme-park-amplify-role-${accountId}"
echo $s3_deploy_bucket
aws s3 mb s3://$s3_deploy_bucket

cd ~/environment/theme-park-backend/1-app-deploy/amplify-role/
sam build
sam package --output-template-file packaged.yaml --s3-bucket $s3_deploy_bucket
sam deploy --template-file packaged.yaml --stack-name theme-park-amplify-role --capabilities CAPABILITY_IAM



#############Deploy the site with the AWS Amplify Console
while true; do
    read -p "Manually create Amplify App on AWS Console Amplify App and type 'y' to continue: " y
    case $y in
        [Yy]* ) echo "Nice, preparing to run module1b-script.sh"; break;;
        * ) echo "Please type y or Y to once you've created Amplify app and are ready to continue";;
    esac
done