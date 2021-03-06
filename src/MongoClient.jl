type MongoClient
    uri::String
    _wrap_::Ptr{Void}

    MongoClient(uri::String) = begin
        uriCStr = bytestring(uri)
        client = new(
            uri,
            ccall(
                (:mongoc_client_new, libmongoc),
                Ptr{Void}, (Ptr{Uint8}, ),
                uriCStr
                )
            )
        finalizer(client, destroy)
        return client
    end

    MongoClient(host::String, port::Int) = MongoClient("mongodb://$host:$port/")
	MongoClient(host::String, port::Int, user::String, password::String) = MongoClient("mongodb://$user:$password@$host:$port/")
	MongoClient(host::String, user::String, password::String) = MongoClient("mongodb://$user:$password@$host/")
	MongoClient(host::String, user::String, password::String, db::String) = MongoClient("mongodb://$user:$password@$host/$db")
    MongoClient() = MongoClient("localhost", 27017)
end
export MongoClient

show(io::IO, client::MongoClient) = print(io, "MongoClient($(client.uri))")
export show

# Private

destroy(client::MongoClient) =
    ccall(
        (:mongoc_client_destroy, libmongoc),
        Void, (Ptr{Void},),
        client._wrap_
        )
