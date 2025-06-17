# reader
path "/secret/*" {
    capabilities = ["read", "list"]
}

# manager
path "/secret/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}