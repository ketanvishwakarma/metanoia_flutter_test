import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:metanoia_flutter_test/common.dart';
import 'package:metanoia_flutter_test/product/cartmodel.dart';
import 'package:metanoia_flutter_test/product/productmodel.dart';
import 'package:metanoia_flutter_test/singnUpLogIn/authentication_service.dart';
import 'package:metanoia_flutter_test/user/user_profile.dart';
import 'package:metanoia_flutter_test/user/usermodel.dart';
import 'package:provider/provider.dart';

CartModel _cart = new CartModel();

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Product> productList = [];
  String dropdown = 'All';
  String imgStarbucks = '', imgMap = '', imgIce = '', imgProduct = '';

  //loaded Images From Database
  loadImages() {
    FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
    _firebaseStorage = FirebaseStorage.instance;
    _firebaseStorage
        .ref()
        .child('Starbucks.jpg')
        .getDownloadURL()
        .then((value) {
      setState(() {
        imgStarbucks = value;
      });
    });
    _firebaseStorage.ref().child('map.png').getDownloadURL().then((value) {
      setState(() {
        imgMap = value;
      });
    });
    _firebaseStorage
        .ref()
        .child('person-holding-starbucks.jpg')
        .getDownloadURL()
        .then((value) {
      setState(() {
        imgIce = value;
      });
    });
    _firebaseStorage
        .ref()
        .child('top-view-cup-coffee.jpg')
        .getDownloadURL()
        .then((value) {
      setState(() {
        imgProduct = value;
      });
    });
  }

  @override
  void initState() {
    //Fetch Products
    ProductDatabaseService().getProducts().then((value) {
      setState(() {
        productList = value;
      });
    });
    loadImages();
    super.initState();
  }

  bool checkAlreadyAddedToCart(Product product) {
    return _cart.productCartItems.length > 0 &&
        _cart.productCartItems
                .firstWhere((element) => product.id == element.id,
                    orElse: () => CartProduct(quantity: 0))
                .quantity! >
            0;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthenticationService>().firebaseAuth;

    //Cart Update Checker
    _cart.addListener(() {
      setState(() {});
    });

    return Scaffold(
        body: SafeArea(
      child: auth.currentUser!.emailVerified == false && auth.currentUser!.email != ''
          ? AlertDialog(
              content: Text(
                  'We have sent you a email verification link, Please verify your email. Then again login'),
              actions: [
                SizedBox(
                  height: 30,
                  width: 80,
                  child: gradientBorderButton('Ok', () {
                    auth.signOut();
                  }),
                )
              ],
            )
          : CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    getBanner(),
                    Padding(
                      padding: getPadding(),
                      child: getShopDetails(),
                    ),
                    Divider(
                      thickness: 5,
                    ),
                    Padding(
                      padding: getPadding(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(14)),
                              child: Icon(
                                Icons.people_alt_outlined,
                                color: Colors.black38,
                                size: 20,
                              )),
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              '2990+ orders placed to make people smile',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 5,
                    ),
                    Padding(
                      padding: getPadding(),
                      child: Text('Promotion',
                          style: Theme.of(context).textTheme.headline5),
                    ),
                    getHorizontalProduct(),
                    Padding(
                      padding: EdgeInsets.only(left: 30, top: 30),
                      child: Text(
                        'Menu',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                    Padding(
                      padding: getPadding(),
                      child: Container(
                        height: 35,
                        alignment: Alignment.topLeft,
                        child: gradientBorder(
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: Text(dropdown),
                              items: <String>['All', 'A', 'B', 'C', 'D']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                dropdown = value!;
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: productGrid(),
                    ),
                    Container(
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: Offset.fromDirection(
                              4.7,
                            ))
                      ]),
                      height: 100,
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      child: gradientButton(
                        'Checkout - \$' + _cart.totalPrice().toString(),
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShoppingCart(),
                            )),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
    ));
  }

  Widget getBanner() {
    return Container(
      height: 250,
      width: double.infinity,
      child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.topLeft,
          children: <Widget>[
            imgStarbucks != ''
                ? Image.network(
                    imgStarbucks,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/loading.jpg',
                    fit: BoxFit.cover,
                  ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(8)),
                      child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => SystemNavigator.pop())),
                  Container(
                      height: 40,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.deepOrange[300],
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        '★ 4',
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(color: Colors.white),
                      )),
                ],
              ),
            )
          ]),
    );
  }

  Widget getShopDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Starbucks Coffee',
                style: Theme.of(context).textTheme.headline4),
            SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(children: [
                WidgetSpan(
                    child: Icon(
                  Icons.location_on,
                  color: Colors.black38,
                  size: 18,
                )),
                TextSpan(
                    text: 'Avenue St. 187',
                    style: Theme.of(context).textTheme.subtitle2),
              ]),
            ),
          ],
        ),
        Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                color: Colors.black,
                image: imgMap != ''
                    ? DecorationImage(
                        colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(.8), BlendMode.dstATop),
                        image: NetworkImage(imgMap),
                        fit: BoxFit.cover)
                    : DecorationImage(
                        image: AssetImage('assets/loading.jpg'),
                        fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(14)),
            child: IconButton(
              icon: Icon(
                Icons.location_on,
                color: Colors.red,
              ),
              onPressed: () => null,
            )),
      ],
    );
  }

  Widget getHorizontalProduct() {
    return Container(
      height: 120,
      child: PageView.builder(
        controller: PageController(viewportFraction: .8),
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Center(
            child: SizedBox(
                height: 90,
                child: beautifulCard(
                    ListTile(
                      leading: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: imgIce != ''
                                ? DecorationImage(
                                    image: NetworkImage(imgIce),
                                    fit: BoxFit.cover)
                                : DecorationImage(
                                    image: AssetImage('assets/loading.jpg'),
                                    fit: BoxFit.cover)),
                      ),
                      title: Text(
                        'Iced Cappuccino',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      subtitle: Text(
                        '\$20',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    EdgeInsets.only(right: 20))),
          );
        },
        itemCount: 5,
      ),
    );
  }

  Widget productGrid() {
    return productList.length > 0
        ? GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              return beautifulCard(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)),
                          child: Stack(
                              fit: StackFit.loose,
                              alignment: Alignment.topLeft,
                              children: <Widget>[
                                imgProduct != ''
                                    ? Image.network(
                                        imgProduct,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset('assets/loading.jpg'),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(218, 181, 147, 1),
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(4),
                                          bottomRight: Radius.circular(4))),
                                  child: Text(
                                    'Popular',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: likeButton(productList[index]),
                                ),
                              ]),
                        ),
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productList[index].numOfOrder.toString() +
                                  '+ Ordered',
                            ),
                            Text(
                              productList[index].name,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('\$' + productList[index].price.toString(),
                                    style:
                                        Theme.of(context).textTheme.headline5),
                                SizedBox(
                                    height: 30,
                                    child: checkAlreadyAddedToCart(
                                            productList[index])
                                        ? gradientBorderButton('Add More', () {
                                            _cart.add(productList[index]);
                                          })
                                        : gradientButton('Add', () {
                                            _cart.add(productList[index]);
                                          }))
                              ],
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                  EdgeInsets.all(10));
            },
            itemCount: productList.length,
          )
        : Center(child: CircularProgressIndicator());
  }

  //LikeDislike
  Widget likeButton(Product product) {
    final user = context.watch<MyUser?>();
    bool liked = product.like.contains(user!.uid);
    return IconButton(
        icon: Icon(
          Icons.favorite,
          color: liked ? Colors.redAccent : Colors.grey,
          size: 30,
        ),
        onPressed: () async {
          setState(() {
            liked ? product.like.remove(user.uid) : product.like.add(user.uid);
            ProductDatabaseService().updateLike(product.id, product.like);
          });
        });
  }
}

class ShoppingCart extends StatelessWidget {
  const ShoppingCart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(
                Icons.logout,
              ),
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthenticationService>().signOut();
              }),
          IconButton(
              icon: Icon(
                Icons.person,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(),
                    ));
              }),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                child: Card(
                    elevation: 10,
                    child: ListTile(
                      title: Text(_cart.productCartItems[index].name!),
                      subtitle: Text('\$' +
                          _cart.productCartItems[index].price!.toString()),
                      trailing: Text('x' +
                          _cart.productCartItems[index].quantity!.toString()),
                    )),
              );
            },
            itemCount: _cart.productCartItems.length,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('Total Price : \$' + _cart.totalPrice().toString()),
          ),
        ],
      ),
    );
  }
}
