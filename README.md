# Bangladesh config  
Bangladesh implementation configuration  

## List of dependencies and artefact. 
https://docs.google.com/document/d/1jMvSAYu2yyy4MSbJ606gSRlwnCH0922EWf6n2tLaghA/edit?usp=sharing


## Deployment steps  
* Install Zlib as a pre-requirement  
```$ yum install -y https://kojipkgs.fedoraproject.org//packages/zlib/1.2.11/19.fc30/x86_64/zlib-1.2.11-19.fc30.x86_64.rpm```

* Get Bahmni 0.92 installer  
```$ yum install https://dl.bintray.com/bahmni/rpm/rpms/bahmni-installer-0.92-155.noarch.rpm -y```

* Get the bahmni configuration files  
```$ cd /etc/bahmni-installer/deployment-artifacts/ && wget https://github.com/DWB-eHealth/bangladesh-config/archive/master.zip && unzip master.zip && mv bangladesh-config bangladesh_config && rm master.zip```

* Get the /etc/bahmni-installer/setup.yml with Dhaka timezone and implementation_name: bangladesh  
```$ cp /etc/bahmni-installer/deployment-artifacts/bangladesh_config/etc/bahmni-installer/setup.yml /etc/bahmni-installer/```

* Get the inventory file /etc/bahmni-installer/prod with bahmni-emr, bahmni-emr-db, bahmni-reports, bahmni-reports-db  
```$ cp /etc/bahmni-installer/deployment-artifacts/bangladesh_config/etc/bahmni-installer/prod /etc/bahmni-installer/```

* Get the latest database snapshot  
```$ cp /etc/bahmni-installer/deployment-artifacts/bangladesh_config/database-snapshots/latest-openmrs_backup.sql /etc/bahmni-installer/deployment-artifacts/openmrs_backup.sql```

* Run the installer  
```$ bahmni -i prod install```

* Load Initializer configuration files - Optional if database snapshot is imported  
```$ sudo ln -s  /var/www/bahmni_config/configuration/ /opt/openmrs/configuration```

* Install the modules and restart OpenMRS using the playbooks  
```$ ansible-playbook /var/www/bahmni_config/playbooks/all.yml -i /etc/bahmni-installer/prod --extra-vars '@/var/www/bahmni_config/playbooks/setup.yml'```

### Appointments scheduling V2 setup  
* The installation of the Appointment scheduling V2 (OMOD module and frontend UI) are deployed through the playbooks. The only manual step to be completed across environments is the HTTPD alias addition in `/etc/httpd/conf.d/ssl.conf`  
`Alias /appointments-v2 /var/www/appointments`  
`$ systemctl restart httpd`  
