import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/product_model.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsList = prefs.getStringList('products') ?? [];
    setState(() {
      products = productsList
          .map((item) => ProductModel.fromJson(item))
          .toList();
    });
  }

  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsList = products.map((p) => p.toJson()).toList();
    await prefs.setStringList('products', productsList);
  }

  Future<void> addProduct(ProductModel product) async {
    setState(() => products.add(product));
    await saveProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil ditambahkan')),
    );
  }

  Future<void> editProduct(int index, ProductModel updatedProduct) async {
    setState(() => products[index] = updatedProduct);
    await saveProducts();
  }

  Future<void> deleteProduct(int index) async {
    setState(() => products.removeAt(index));
    await saveProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus')));
  }

  Future<String> convertImageToBase64(XFile image) async {
    Uint8List bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  void showForm({ProductModel? product, int? index}) {
    TextEditingController nameController = TextEditingController(
      text: product?.name ?? '',
    );
    TextEditingController descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    TextEditingController priceController = TextEditingController(
      text: product != null ? product.price.toString() : '',
    );
    TextEditingController imageController = TextEditingController(
      text: product?.image ?? '',
    );

    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    //metod untuk memilih gambar dari galeri
    Future<void> pickImage() async {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          selectedImage = image;
          imageController.text = image.path;
        });
      }
    }

    Widget buildPreviewImage() {
      // jika gambar baru dipilih, maka tampilkan gambar tersebut
      if (selectedImage != null) {
        return FutureBuilder<Uint8List>(
          future: selectedImage!.readAsBytes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            return Image.memory(
              snapshot.data!,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            );
          },
        );
      }

      //jika gambar sudah ada di produk, maka tampilkan gambar tersebut
      if (product?.image.isNotEmpty ?? false) {
        return Image.memory(
          base64Decode(product!.image),
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        );
      }

      return Container(
        width: 150,
        height: 150,
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 48, color: Colors.grey),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Produk',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga Produk'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => pickImage(),
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 10),
              buildPreviewImage(),

            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                nameController.dispose();
                descriptionController.dispose();
                priceController.dispose();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                String imageBase64 = product?.image ?? '';
                if (selectedImage !=null){
                  imageBase64 = await convertImageToBase64(
                    selectedImage!,
                    );
                }


                final newProduct = ProductModel(
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  image: imageBase64
                );
                if (product == null) {
                  addProduct(newProduct);
                } else {
                  editProduct(index!, newProduct);
                }
                Navigator.pop(context);
                nameController.dispose();
                descriptionController.dispose();
                priceController.dispose();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text('Daftar Produk'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),

      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text('Belum ada produk'))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailPage(product: product),
                              ),
                            );
                          },
                          onEdit: () =>
                              showForm(product: product, index: index),
                          onDelete: () => deleteProduct(index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
