
DHServer.java

import java.net.*;

import java.io.*;

public class DHServer |

public static void main(String[] args) throws IOException

1

try!

int port 8088;

// Server Key int b=3;

// Client p. g, and key

double clientP, clientG, clientA, B, Bdash;

String Batr,

// Established the Connection

ServerSocket serverSocket new ServerSocket(port); System.out.println("Waiting for client on port serverSocket.getLocalPort() +

Socket server serverSocket.accept();

System.out.println("Just connected to server.getRemoteSocketAddress());

// Server's Private Key

System.out.println("From Server: Private Key +bj:

// Accepts the data from client

DataInputStream in new DataInputStream(server.getInputStream());

clientP Integer.parseInt(in.readUTF()); // to accept p System.out.println("From Client: P clientP);

clientG Integer.parseInt(in.readUTF()); // to accept g System.out.println("From Client: G clientG);

clientA Double.parseDouble(in.readUTF()); // to accept A System.out.println("From Client: Public Key + clientA);

B=((Math.pow(clientG, b)) % clientP); // calculation of B Bstr Double.toString(B);

// Sends data to client

// Value of B

OutputStream outToclient server.getOutputStream(); DataOutputStream out new DataOutputStream(outToclient);

VVIT

Madhu Babu Janjanam

Cryptography and Network Security Lab

out.writeUTF(Bstr); // Sending B

Bdash ([Math.pow(clientA, bj) % clientP); // calculation of Bdash System.out.println('Secret Key to perform Symmetric Encryption + Bdash);

server.close();

catch (SocketTimeoutExceptions)

System.out.println("Socket timed out!");

1

catch (IOException e) [

1

1

1
DHClient.java

import java.net.*;

import java.io.*;

public class DHClient |

public static void main(String[] args)

try

String pstr. gstr, Astr, String serverName "localhost": int port 8088;

// Declare p. g, and Key of client

int p-23:

int g = 9; int a4;

double Adash, serverB;

// Established the connection

System.out.println("Connecting to + serverName

Socket client new Socket(serverName, port);

on port port); System.out.println("Just connected to " client.getRemote SocketAddress[]];

// Sends the data to client

OutputStream outToServer client.getOutputStream(); DataOutputStream out new DataOutputStream(outToServer);

pstr Integer.toString(p); out.writeUTF(pstr); // Sending p

gstr Integer.toString(g): out.write UTFigstr); // Sending g

VVIT

1

Madhu Babu Janjanam

Cryptography and Network Security Lab

double A ((Math.pow(g, a)) % p); // calculation of A Astr Double.toString(A);

out.write UTF(Astr); // Sending A

//Client's Private Key System.out.println("From Client: Private Key a):

// Accepts the data

DataInputStream in new DataInputStream(client.getInputStream()); serverB Double.parseDouble(in.readUTF()); System.out.println("From Server: Public Key serverB);

Adash ((Math.pow(serverB, a)) % p); // calculation of Adash System.out.println('Secret Key to perform Symmetric Encryption" Adash): client.close();

catch (Exception e) | e.printStackTrace();
