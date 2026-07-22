// Reference version: A0.0.1
get println from std::io
get tcp_connect, tcp_write, tcp_read, tcp_close from std::net
get result_unwrap, is_err from std::res
get concat from std::str
get to_string, to_hex from std::types

dec string OPCODE_SET = ""
dec string OPCODE_GET = ""
dec string OPCODE_TEMP = ""
dec string OPCODE_CONST = ""
dec string OPCODE_SIGNAL = ""
dec string OPCODE_SUB = ""

dec string DEL = ""
dec string END = "\0" 

record NetworkClient {
    bool is_connected,
    int conn,
    string buffer
}

fn client_new() -> NetworkClient {
    dec NetworkClient client = NetworkClient {
        is_connected: false,
        conn: -1,
        buffer: ""
    }
    return client
}

fn client_init(NetworkClient client, string host, int port) -> bool {
    dec string port_str = result_unwrap(to_string(port))
    
    dec string address = concat(host, ":", port_str)
    dec int stream = result_unwrap(tcp_connect(address))

    if (stream < 0) {
        client.is_connected = false
        return false
    }

    client.conn = stream
    client.is_connected = true
    client.buffer = ""
    return true
}

fn client_send_cmd(NetworkClient client, string opcode, arr[string] args, bool is_signal) {
    if (!client.is_connected) {
        return
    }

    dec string msg = opcode

    for arg in args {
        msg = concat(msg, arg, DEL)
    }

    if (is_signal) {
        msg = concat(msg, END)
    }

    tcp_write(client.conn, msg)
}

fn client_get(NetworkClient client, string key) -> string {
    if (!client.is_connected) {
        return ""
    }

    dec arr[string] args = [key]
    client_send_cmd(client, OPCODE_GET, args, false)

    dec string temp_buffer = ""
    while (true) {
        dec string rbyte = tcp_read(client.conn, 1)?
        if (rbyte == "" or rbyte == DEL) {
            return temp_buffer
        }
        temp_buffer = concat(temp_buffer, rbyte)
    }
    return temp_buffer
}

fn client_set(NetworkClient client, string key, string val) {
    dec arr[string] args = [key, val]
    client_send_cmd(client, OPCODE_SET, args, false)
}

fn client_temp(NetworkClient client, string key, string val) {
    dec arr[string] args = [key, val]
    client_send_cmd(client, OPCODE_TEMP, args, false)
}

fn client_const(NetworkClient client, string key, string val) {
    dec arr[string] args = [key, val]
    client_send_cmd(client, OPCODE_CONST, args, false)
}

fn client_sub(NetworkClient client, string key) {
    dec arr[string] args = [key]
    client_send_cmd(client, OPCODE_SUB, args, false)
}

fn client_signal(NetworkClient client, arr[string] args) {
    client_send_cmd(client, OPCODE_SIGNAL, args, true)
}

fn client_update_game_network(NetworkClient client) -> string {
    if (!client.is_connected) {
        return ""
    }

    while (true) {
        dec string byt = tcp_read(client.conn, 1)?

        if (byt == "") {
            return ""
        }

        if (byt == DEL) {
            dec string msg = client.buffer
            client.buffer = ""
            return msg
        } else {
            client.buffer = concat(client.buffer, byt)
        }
    }
}
