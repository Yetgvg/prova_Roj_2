import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prova 2 Rojerio',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: LoginScreen(),
    );
  }
}

// Tela de Login
class LoginScreen extends StatelessWidget {
  final TextEditingController UsuarioController = TextEditingController();
  final TextEditingController SenhaController = TextEditingController();

  void validateLogin(BuildContext context) {
    final usuario = UsuarioController.text;
    final senha = SenhaController.text;

    if (usuario == 'teste' && senha == '123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProdutoScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro'),
          content: Text('Usuário ou senha inválidos'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 214, 214, 214),
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: const Color.fromARGB(255, 97, 97, 97),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ClipOval(
              child: const Image(
                image: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ2owgtagk4Mo5wda4EOalu3DOhscqDf8onng&s',
                ),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: UsuarioController,
              decoration: InputDecoration(
                labelText: 'Usuário',
              ),
            ),
            TextField(
              controller: SenhaController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => validateLogin(context),
              child: Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------- //

// Tela Principal
class ProdutoScreen extends StatefulWidget {
  @override
  _ProdutoScreenState createState() => _ProdutoScreenState();
}

class _ProdutoScreenState extends State<ProdutoScreen> {
  final String apiUrl = 'http://localhost:3000/produtos';
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController custoController = TextEditingController();
  final TextEditingController precoController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();

  // Criação da variavel para listar os produtos e ID do produto para CRUD.
  List produtos = [];
  int? selectProdutoID;

  // Função para limpar os campos
  void LimparCampos() {
    nomeController.clear();
    custoController.clear();
    precoController.clear();
    categoriaController.clear();
    selectProdutoID = null;
  }

  // Função para Alocar os dados do produtos para os campos no formulario
  void selectProduct(Map product) {
    setState(() {
      selectProdutoID = product['id'];
      nomeController.text = product['nome'];
      custoController.text = product['precoCusto'].toString();
      precoController.text = product['precoVenda'].toString();
      categoriaController.text = product['categoria'];
    });
  }

  // Trazer os produtos ao carregar a pagina
  @override
  void initState() {
    super.initState();
    fetchProdutos();
  }

  // Rota para trazer e atualizar a Lista de produtos da API
  Future<void> fetchProdutos() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        produtos = json.decode(response.body);
      });
    }
  }

  // Rota para Criar e Atualizar produto
  Future<void> createOrUpdateProduct() async {
    // Pegar variaveis do formulario
    final product = {
      'nome': nomeController.text,
      'precoCusto': double.parse(custoController.text),
      'precoVenda': double.parse(precoController.text),
      'categoria': categoriaController.text,
    };

    // Verifica se o produto tem ID, caso não => cria produto, caso sim => atualiza produto
    if (selectProdutoID == null) {
      // Criar novo produto
      final response = await http.post(
        Uri.parse('http://localhost:3000/produto'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product),
      );
      // Atualiza a Lista
      if (response.statusCode == 201) {
        fetchProdutos();
      }
    } else {
      // Atualizar produto existente
      final response = await http.put(
        Uri.parse('http://localhost:3000/produto/$selectProdutoID'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product),
      );
      // Atualiza a Lista
      if (response.statusCode == 200) {
        fetchProdutos();
      }
    }

    // No final chama a função que limpa os campos
    LimparCampos();
  }

  // Rota para deletar os produtos
  Future<void> deleteProduct(int id) async {
    final response =
        await http.delete(Uri.parse('http://localhost:3000/produto/$id'));
    if (response.statusCode == 200) {
      fetchProdutos();
    }
  }

  // Tela formulario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 214, 214, 214),
      appBar: AppBar(
        title: Text('CRUD Produtos'),
        backgroundColor: const Color.fromARGB(255, 97, 97, 97),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipOval(
              child: const Image(
                image: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ2owgtagk4Mo5wda4EOalu3DOhscqDf8onng&s',
                ),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: custoController,
              decoration: InputDecoration(labelText: 'Preço de Custo'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: precoController,
              decoration: InputDecoration(labelText: 'Preço de Venda'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: categoriaController,
              decoration: InputDecoration(labelText: 'Categoria'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: createOrUpdateProduct,
              child: Text(selectProdutoID == null ? 'Adicionar' : 'Atualizar'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: produtos.length,
                itemBuilder: (context, index) {
                  final product = produtos[index];
                  return ListTile(
                    title: Text(product['nome']),
                    subtitle: Text('R\$ ${product['precoVenda']}'),
                    onTap: () => selectProduct(product),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteProduct(product['id']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
