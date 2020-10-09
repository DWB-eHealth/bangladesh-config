# bangladesh-config  
Bangladesh implementation configuration  


## Deployment steps  
Install Zlib as a pre-requirement  
```$ yum install -y https://kojipkgs.fedoraproject.org//packages/zlib/1.2.11/19.fc30/x86_64/zlib-1.2.11-19.fc30.x86_64.rpm```

Get Bahmni 0.92 installer  
```$ yum install -y https://dl.bintray.com/bahmni/rpm/rpms/bahmni-installer-0.92-155.noarch.rpm```

Get the bahmni configuration files  
```$ cd /etc/bahmni-installer/deployment-artifacts/ && wget https://github.com/DWB-eHealth/bangladesh-config/archive/master.zip && unzip master.zip && mv bangladesh-config bangladesh_config && rm master.zip```

Get the /etc/bahmni-installer/setup.yml with Dhaka timezone and implementation_name: bangladesh  
```$ cp /var/www/bahmni_config/etc/bahmni-installer/setup.yml /etc/bahmni-installer/setup.yml```

Get the inventory file /etc/bahmni-installer/prod with bahmni-emr, bahmni-emr-db, bahmni-reports, bahmni-reports-db  
```$ cp /var/www/bahmni_config/etc/bahmni-installer/prod /etc/bahmni-installer/prod```

Get the latest database snapshot  
```$ cp /var/www/bahmni_config/database-snapshots/latest-openmrs_backup.sql /etc/bahmni-installer/deployment-artifacts/openmrs_backup.sql```

Run the installer  
```$ bahmni -i prod install```

Load Initializer configuration files - Optional if database snapshot is imported  
```$ cp -R /var/www/bahmni_config/configuration/ /opt/openmrs/configuration/```

Install the modules and restart OpenMRS using the playbooks  
```$ ansible-playbook /var/www/bahmni_config/playbooks/all.yml -i /etc/bahmni-installer/prod --extra-vars '@/var/www/bahmni_config/playbooks/setup.yml'```
