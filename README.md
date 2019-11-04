# VTechData

VTechData is an online repository based on the Samvera/Fedora/Solr software stack intended to facilitate the preservation, discovery, and sharing of datasets.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

VTechData is a Ruby on Rails application that relies on the Samvera Sufia collection of gems. It also leverages the Fedora triple-store, Solr for indexing and search functionality, and FITS for file characterization.

* Sufia:
  - https://hyrax.samvera.org/ 
  - https://github.com/samvera-deprecated/sufia

* Fedora: https://duraspace.org/fedora/

* Solr: https://lucene.apache.org/solr/

* FITS: https://projects.iq.harvard.edu/fits/home

If you would like to use VT's InstallScript tools then you will need:

* Vagrant: https://www.vagrantup.com/

* Ansible: https://www.ansible.com/

* Virtualbox: https://www.virtualbox.org/

### Installing

The easiest way to install VTechData is to use the `InstallScripts` tool developed by University Libraries at Virginia Tech. https://github.com/VTUL/InstallScripts

Clone the repo to your preferred location and begin by creating `ansible/site_secrets.yml` based on `ansible/example_site_secrets.yml` and editing it.

Set the project_name to "compel" on line 7
`project_name: 'data-repo'`

Set the application environment to either development or production on line 11
`project_app_env: 'development'`

If running in production you must generate a secret_key_base which can be added on line 15
It can be generated using `openssl rand -hex 64`
`project_secret_key_base: '<generated value>'`


Set ansible_user to "vagrant" on line 166 and uncomment the entire line.
`ansible_user: 'vagrant'`

From the Installscripts root directory run `vagrant up` to create a new VM and provision it with the dependencies necessary to run and serve VTechData.



## Contributing

Please read [CONTRIBUTING.md](https://github.com/VTUL/data-repo/blob/master/CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/VTUL/compel/tags). 

## Authors

* **Yinlin Chen @yinlinchen**
* **Lee Hunter @whunter**
* **Tingting Jiang @tingtingjh**
* **Janice Kim @shabububu**
* **Paul Mather @pmather**

## License

This project is licensed under the MIT License

