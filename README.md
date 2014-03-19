Présentation Vagrant et Packer
==============================

Etape 1 : VM simple
-------------------

### Features

- Une VM basée sur la box [saucy-server-amd64](http://cloud-images.ubuntu.com/vagrant/saucy/current/saucy-server-cloudimg-amd64-vagrant-disk1.box)
- Pas configuration spécifique (réseau...)
- Provisioning : script Shell vide
- **Démarrage en 30 secondes**

### Démarrer la VM

    $ cd 1_simple_vagrant_vm
    $ vagrant up
    Bringing machine 'default' up with 'virtualbox' provider...
    ...
    
    $ vagrant ssh
    ...
    
    $ vagrant destroy
    ...

Etape 2 : Multi-VM
------------------

### Features

- 3 VMs basées sur la box [saucy-server-amd64](http://cloud-images.ubuntu.com/vagrant/saucy/current/saucy-server-cloudimg-amd64-vagrant-disk1.box) :
    - 2 back-ends Apache servant chacun un fichier statique
    - 1 front-end Nginx en load-balancer (round-robin sur les deux back-ends)
- Provisionning par scripts Shell 
- Redirection des ports 80 vers l'hôte :
    - back-end-1:80 -> 8011
    - back-end-2:80 -> 8012
    - front-end:80 -> 8010
- Adresses IP statiques sur réseau "interne" 192.168.1.x
    - uniquement pour la communication des VMs entre elles
- **Démarrage en 2 minute 30**

### Démarrer une VM

    $ cd 2_vagrant-with-standard-boxes
    $ vagrant up back-end-1
    Bringing machine 'back-end-1' up with 'virtualbox' provider...
    ...
    
    $ curl localhost:8011
    <html><body><h1>Je suis le back-end #1</h1></body></html>

### Démarrer toutes les VMs

    $ cd 2_vagrant-with-standard-boxes
    $ vagrant up
    Bringing machine 'back-end-1' up with 'virtualbox' provider...
    ...
    Bringing machine 'back-end-2' up with 'virtualbox' provider...
    ...
    Bringing machine 'front-end' up with 'virtualbox' provider...
    ...
    
    $ curl localhost:8011
    <html><body><h1>Je suis le back-end #1</h1></body></html>
    
    $ curl localhost:8012
    <html><body><h1>Je suis le back-end #2</h1></body></html>
    
    $ curl localhost:8010
    <html><body><h1>Je suis le back-end #1</h1></body></html>
    
    $ curl localhost:8010
    <html><body><h1>Je suis le back-end #2</h1></body></html>
    
    $ curl localhost:8010
    <html><body><h1>Je suis le back-end #1</h1></body></html>

Etape 3 : Boxes repackagées
---------------------------

### Features

- 3 VMs basées sur des boxes repackagées
- Provisionning inutile
- Redirection des ports 80 vers l'hôte :
    - back-end-1:80 -> 9011
    - back-end-2:80 -> 9012
    - front-end:80 -> 9010
- Adresses IP statiques sur un second réseau "interne" 192.168.1.x
    - isolation par rapport au réseau de l'étape 2
- **Démarrage en 1 minute 30**

### Repackager les boxes de l'étape 2

    $ cd 2_vagrant-with-standard-boxes
    
    $ VBoxManage list vms
    "2_vagrant-with-standard-boxes_front-end_1395157474108_74569" {1e1cbc10-884b-49b0-b102-d5ab721e901b}
    ...
    
    $ vagrant package --base 2_vagrant-with-standard-boxes_front-end_1395157474108_74569 --output front-end.box
    [2_vagrant-with-standard-boxes_front-end_1395157474108_74569] Attempting graceful shutdown of VM...
    [2_vagrant-with-standard-boxes_front-end_1395157474108_74569] Clearing any previously set forwarded ports...
    [2_vagrant-with-standard-boxes_front-end_1395157474108_74569] Exporting VM...
    [2_vagrant-with-standard-boxes_front-end_1395157474108_74569] Compressing package to: /Users/aseigneurin/dev/pres-vagrant/2_vagrant-with-standard-boxes/front-end.box
    
    $ vagrant box add front-end front-end.box
    Downloading box from URL: file:/Users/aseigneurin/dev/pres-vagrant/2_vagrant-with-standard-boxes/front-end.box
    Extracting box...te: 274M/s, Estimated time remaining: 0:00:01)
    Successfully added box 'front-end' with provider 'virtualbox'!
    
    $ vagrant package --base 2_vagrant-with-standard-boxes_back-end-1_1395157553886_83971 --output back-end-1.box
    ...
    $ vagrant box add back-end-1 back-end-1.box
    ...
    $ vagrant package --base 2_vagrant-with-standard-boxes_back-end-2_1395157623376_40688 --output back-end-2.box
    ...
    $ vagrant box add back-end-2 back-end-2.box
    ...

### Lister les boxes locales

    $ vagrant box list
    back-end-1          (virtualbox)
    back-end-2          (virtualbox)
    front-end           (virtualbox)
    ...

### Démarrer les VMs

    $ cd 3_vagrant-with-repackaged-boxes
    $ vagrant up
    ...
    
    $ curl localhost:9011
    <html><body><h1>Je suis le back-end #1</h1></body></html>
    
    $ curl localhost:9012
    <html><body><h1>Je suis le back-end #2</h1></body></html>
    
    $ curl localhost:9010
    <html><body><h1>Je suis le back-end #1</h1></body></html>
    
    $ curl localhost:9010
    <html><body><h1>Je suis le back-end #2</h1></body></html>
    
    $ curl localhost:9010
    <html><body><h1>Je suis le back-end #1</h1></body></html>

Etape 4 : Création d'une VM from scratch avec Veewee
----------------------------------------------------

### Features

- Création d'une VM à partir d'une ISO Ubuntu
- Source du template : https://github.com/jedi4ever/veewee/tree/master/templates/ubuntu-13.10-server-amd64
- **Création de la box en ~30 minutes**

### Préparation de la box

    $ cd 4_veewee
    $ bundle exec veewee vbox build ...
    ...
    
    $ vagrant box add ubuntu-13.10-server-amd64 ubuntu-13.10-server-amd64.box
    ...

Etape 5 : Création d'une VM from scratch avec Packer
----------------------------------------------------

### Features

- Création d'une VM à partir d'une ISO Ubuntu
- **Création de la box en ~30 minutes**

### Conversion du template Veewee en template Packer

    $ cd 5_packer
    $ veewee-to-packer ../4_veewee/definition.rb --output .
    Success! Your Veewee definition was converted to a Packer template!
    The template can be found in the `template.json` file in the output
    directory: output

Puis, éditer le fichier "template.json" :

- Supprimer les blocs "vmware" dans les blocs "provisioners" et "builders".
- Renommer les blocs "virtualbox" en "virtualbox-iso".

### Préparation de la box

    $ packer build template.json
    ...
    ==> Builds finished. The artifacts of successful builds are:
    --> virtualbox-iso: 'virtualbox' provider box: packer_virtualbox-iso_virtualbox.box
    
    $ vagrant box add ubuntu-13.10-server-amd64 packer_virtualbox-iso_virtualbox.box
    ...
