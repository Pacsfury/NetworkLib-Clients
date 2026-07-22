// Send a SET messsage to server and then retrieve the value
get nl

fn main() {
    dec NetworkClient myclient = client_new()
    dec bool conn_ok = client_init(myclient, "127.0.0.1", 8080)

    if (conn_ok) {
        println("Connected to server.")
        
        client_set(myclient, "pts", "100")
        println(client_get(myclient, "pts")) //this will print 100
        
        println("Sent a test SET")
    } else {
        println("Error connecting to server")
    }
}
