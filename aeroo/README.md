# Aeroo Docs

docker run --detach \
    --name=aeroo \
    --restart=always \
    --hostname aeroo \
    --env AEROO_PORT={AEROO_PORT} \
    unisis/aeroo
