# Cert-Dumper
Read Certificate from Traefik

## Usage

#### usage all Certificates:  

       acme.sh </path/to> </dest/path>
       
       </path/to -> acme.json> -> without - acme.json
       
       </dest/path> -> output directory -> </tmp/domain-name>

#### usage 1,2,.. Certificates:  

       acme.sh </path/to> </dest/path> <sub.domain.de>
       
       </path/to -> acme.json> -> without - acme.json
       
       </dest/path> -> output directory -> </tmp/domain-name>
       
       <sub.domain.de> -> single - sub.domain.de or multi - seperated by ',' sub.domain.de,sub2.domain.de,...

## Output

#### example:  

/tmp/domain-name  
  -  private.key

1. /sub  
   - files :
     - cert.pem
     - chain.pem
     - fullchain.pem
     - privkey.pem

2. /sub  
   - files:
     - cert.pem
     - chain.pem
     - fullchain.pem
     - privkey.pem
 
 
