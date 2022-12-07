
docker build -t localhost/jboss-demo-original --file Dockerfile-original .
docker build -t localhost/jboss-demo-modular --file Dockerfile-modular .
docker build -t localhost/jboss-demo-backend --file Dockerfile-backend .
docker build -t localhost/jboss-demo-frontend --file Dockerfile-frontend .


#docker tag localhost/jboss-demo-original quay.io/bfarr/jboss-demo-original
#docker push quay.io/bfarr/jboss-demo-original
#docker tag localhost/jboss-demo-modular quay.io/bfarr/jboss-demo-modular
#docker push quay.io/bfarr/jboss-demo-modular
#docker tag localhost/jboss-demo-backend quay.io/bfarr/jboss-demo-backend
#docker push quay.io/bfarr/jboss-demo-backend
#docker tag localhost/jboss-demo-frontend quay.io/bfarr/jboss-demo-frontend
#docker push quay.io/bfarr/jboss-demo-frontend