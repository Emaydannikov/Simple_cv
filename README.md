Simple-Deploy Automation Solution to Deliver and Build Code from GitHub to Remote AWS EC2 Server.

This solution will help developers speed up the process of creating EC2 instances and security groups on the AWS platform. 

This solution helps to simplify the process of delivering code to the user's Web server immediately after a code update (Pull) on GitHub. When using this solution, you can make 
intermediate tests of the code for the presence of certain words or phrases, as well as check the html code for syntax errors. 

This solution includes the use of the following tools and services: 

- Terraform
- AWS EC2, Route53
- Jenkins
- Github


Also, this solution requires the following elements:

- Registered AWS Account 
- Registered GitHubAccount 
- Terraform installed on your pc  


Stage 1. Preparing to work with Terraform. 

- You will need to obtain AWS credentials. This can be done by going to the IAM section at the following link: https://console.aws.amazon.com/iamv2. Select the "Users" section and then click the "Add User".
- On the “Set user details” page, enter the username and select the “AWS credential type” option - “Access key - Programmatic access” and press the Next button. 
- Next, you need to add the user rights to work with AWS. In the menu “Set permissions” select “Attach existing policies directly” then select “Administrator Access”.  
- The next item “Add tags” is optional.
- The “Review” section will show you information about the user you are creating. Click the Create User button if all information is correct .
- Attention at this stage you have already created a user and this page contains important information. You can see the Access key ID in the open form, copy it, the Secret access key you see in the hidden form, press the show button to display it. ATTENTION Secret access key is issued only once on this page. It will not be possible to get it again for this user. Copy both keys to a safe place. 
- To provide ssh access to future servers, you need to create an ssh key. Follow this link: eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#KeyPairs  click the “Create key pair” button. Enter a name for your key and choose the “Private key file format” convenient for you and click “Create key pair”. Download the key to your computer. 


Stage 2. Working with Terraform 

- Open the Terraform file located in this project for changes in a text editor convenient for you. 
- In the first block of code, you will need to enter your Access key and Secret key obtained earlier. You will also need to specify the region in which you want to create AWS instances. In our case, this is the "eu-central-1" region. 
- Next, you need to replace key_name with the ssh pair you created earlier in AWS. 
- Save the Terraform file. At the command line, enter the terraform init command, this will load the required libraries to work with AWS.
- Next, run the terraform plan command in the output, you will see what will be created in the Amazon cloud using Terraform. In our case, these are 2 EC2 instances and a Security Group for full Internet access. 
- Next, run the terraform apply command to apply and further build the infrastructure. Terraform will take some time to create instances. You can check their availability at the following link  https://eu-central-1.console.aws.amazon.com/ec2 .


Stage 3. Preparing the Web server.

Login with ssh to the instance named “My_Web” created on AWS using Terraform.
Run the following command: sudo apt update && sudo apt install apache2 
You can check the status of web server using the command: sudo systemctl status apache2
If the service does not start automatically, you will need to start manually using the sudo systemctl start apache2 command. If you need to restart the service, use the sudo systemctl restart apache2 command 


Stage 4. Preparing the Jenkins server. 
    
Login with ssh to an instance named “My_Jenkins” created on AWS using Terraform.   
Run the following command: sudo apt update 
Java installation required for Jenkins to work run the following command:
sudo apt install openjdk-11-jdk
Run the following command: sudo wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
Run the following command: sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
Run the following command: sudo apt update 
Run the following command: sudo apt install jenkins
You can check Jenkins status using the command:  sudo systemctl status jenkins
Go in your browser to the address of your server on port 8080, for example:  http://3.69.29.122:8080
Follow the steps on the start page. Choose the recommended set of plugins, it will save time in the future. 




Stage 5. Jenkins configuration.

Go to the Jenkins plugin settings http://your_jenkins_ip:8080/pluginManager/available and install the Publish Over SSH plugin with its help you can go to our web server and place a new version of the site there. 
Go to the Jenkins settings http://your_jenkins_ip:8080/configure find the Publish over SSH and enter your key received earlier on AWS there. 
Add the web server data, Name is an arbitrary name, hostname is the ip address of the previously created instance “My_Web”, Username is ubuntu, Remote Directory is /var/www/html. Be sure to click Apply and Save when you're done setting up. 
Create a new Job http://your_jenkins_ip:8080/view/all/newJob Select “Create a job with free configuration”. 
In “General” select “GitHub project” and specify the ssh link to your repository. For example:  git@github.com:Your_username/Your_project_name.git/ 
In "Source Code Management" select GIT and also specify the ssh link to your repository 
Next, you need to allow Jenkins to use your repository, for this you need to create new ssh keys. Use the ssh-keygen command 
Click the “Add” button and select “Jenkins”. 
“Kind”  choose “SSH Username with private key”
Set  “ID” and “Description”.
Username must match your GitHub login. 
In “Private Key” press “Enter directly”. Enter the contents of the file without the extension created earlier with ssh-keygen 
"Build triggers" select "GitHub hook trigger for GITScm polling" 
You can add additional tests or operations before delivering the code using the "Add build step" button.
To deliver files over ssh to our previously created web server “My_Web”, you can select “Send files or execute commands over SSH” in “Add build step” Select a previously configured server to send data. “Remote directory” you can specify the root directory, because we specified /var/www/html earlier. “Exec command” can send any command to the server after moving project files. I recommend restarting Apache to avoid problems sudo service apache2 restart.  




Stage 6. Configuring GitHub account

To automate code delivery immediately after updating to GitHub, we need to add the ssh key https://github.com/settings/keys. Select “New SSH Key” then enter “Title”. Enter the contents of the * .Pub file created earlier with ssh-keygen 
Go to the settings of the repository that will need to be delivered to the server and configure Webhook. For example https://github.com/Your_username/Your_project_name/settings/hooks, select “Add webhook”, “Payload URL” http: // your_jenkins_ip: 8080 / github-webhook /, “Content type” - “application / json ”. 






Step 7: Configuring a Domain Name on AWS Route 53 (Optional) 

If you need to use a domain name instead of an ip address to access the site, you will need to purchase it from the Route53 service and assign it to your Web server. 

Go to https://console.aws.amazon.com/route53/v2  
Select “Register domain” Enter the desired name for your site. 
You will be redirected to the “Choose a domain name” page where you can choose an available name and a second level domain.
Select the desired domain name, add to cart and complete the payment. 
The purchased domain name can be verified at the following link https://console.aws.amazon.com/route53/home#DomainListing: 
Then go to “Hosted Zone” and select your domain name. https://console.aws.amazon.com/route53/v2/hostedzones   
Click “Create record”. Select “Simple routing” 
Click “Define simple record”. “Value / Route traffic to” select “IP address or another value, depending on the record type” below enter the IP address of your web server. 


Stage 8. Configuring Zabbix Monitoring (Optional) 

If you need to receive reports about server problems and / or their unavailability, you can configure the monitoring system. 

To configure the Zabbix server, you can manually add another EC2 instance. 
Connect using the “ssh key pair” created earlier in your AWS account. 
Configure the server according to the instructions from the software vendor. https://www.zabbix.com/ru/download?zabbix=5.0&os_distribution=ubuntu&os_version=20.04_focal&db=postgresql&ws=nginx
Install zabbix-agent to another monitoring server.  sudo apt install zabbix-agent
Add hosts for monitoring on the Zabbix server. 
You can configure the transmission of Alerts to the Telegram messenger according to the following instructions.   https://serveradmin.ru/nastroyka-opoveshheniy-zabbix-v-telegram/ 
