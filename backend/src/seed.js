require('dotenv').config();
const { connectDb } = require('./config/db');
const Restaurant = require('./models/Restaurant');
const MenuItem = require('./models/MenuItem');
const Category = require('./models/Category');
const Promo = require('./models/Promo');
const Coupon = require('./models/Coupon');

const restaurants = [
  {
    name: 'Dala Tastes',
    description: 'Қазақ тағамдары, үйдегідей дәм',
    cuisine: 'Kazakh',
    imageUrl: 'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?auto=format&fit=crop&w=900&q=80',
    city: 'Алматы',
    rating: 4.8,
    priceLevel: '₸₸',
    deliveryTime: '25-35 мин',
    minOrder: 1500,
    deliveryFee: 0,
    tags: ['Бешбармақ', 'Қуырдақ', 'Дәстүрлі']
  },
  {
    name: 'Steppe Pizza',
    description: 'Ағаш пеш, ерекше қоспалар',
    cuisine: 'Italian',
    imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=900&q=80',
    city: 'Алматы',
    rating: 4.6,
    priceLevel: '₸₸',
    deliveryTime: '20-30 мин',
    minOrder: 2000,
    deliveryFee: 300,
    tags: ['Пицца', 'Комбо', 'Пеш']
  },
  {
    name: 'Central Sushi',
    description: 'Fresh roll және poke',
    cuisine: 'Japanese',
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=900&q=80',
    city: 'Алматы',
    rating: 4.7,
    priceLevel: '₸₸₸',
    deliveryTime: '35-45 мин',
    minOrder: 2500,
    deliveryFee: 400,
    tags: ['Суши', 'Poke', 'Жаңа']
  },
  {
    name: 'Bauyrdaq & Co',
    description: 'Таңғы ас пен десерттер',
    cuisine: 'Bakery',
    imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=900&q=80',
    city: 'Алматы',
    rating: 4.5,
    priceLevel: '₸',
    deliveryTime: '20-30 мин',
    minOrder: 1200,
    deliveryFee: 200,
    tags: ['Баурсақ', 'Десерт', 'Кофе']
  },
  {
    name: 'Green Bowl',
    description: 'Салаттар мен healthy bowl',
    cuisine: 'Healthy',
    imageUrl: 'https://images.unsplash.com/photo-1546069901-5ec6a79120b0?auto=format&fit=crop&w=900&q=80',
    city: 'Алматы',
    rating: 4.6,
    priceLevel: '₸₸',
    deliveryTime: '25-35 мин',
    minOrder: 1800,
    deliveryFee: 300,
    tags: ['Healthy', 'Салат', 'Fit']
  },
  {
    name: 'Burger Caravan',
    description: 'Үлкен бургерлер мен стрит фуд',
    cuisine: 'Burgers',
    imageUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=900&q=80',
    city: 'Алматы',
    rating: 4.4,
    priceLevel: '₸₸',
    deliveryTime: '30-40 мин',
    minOrder: 2000,
    deliveryFee: 350,
    tags: ['Бургер', 'Картошка', 'Street']
  },
  {
    name: 'Thai Silk',
    description: 'Тай асханасы, аздап ащы',
    cuisine: 'Thai',
    imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=900&q=80',
    city: 'Алматы',
    rating: 4.7,
    priceLevel: '₸₸₸',
    deliveryTime: '35-45 мин',
    minOrder: 2500,
    deliveryFee: 400,
    tags: ['Pad Thai', 'Curry', 'Spicy']
  }
];

const categories = [
  { name: 'Популярное' },
  { name: 'Пицца' },
  { name: 'Суши' },
  { name: 'Супы' },
  { name: 'Горячее' },
  { name: 'Десерт' },
  { name: 'Напитки' },
  { name: 'Healthy' },
  { name: 'Бургер' },
  { name: 'Снэк' },
];

const promos = [
  {
    title: 'Kaspi Pay кешбэк',
    subtitle: 'Әр тапсырысқа 5% бонус',
    badge: 'Апта ұсынысы',
    imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80',
    discountPercent: 5,
  },
  {
    title: 'Steppe Pizza',
    subtitle: '2 пицца + сусын',
    badge: 'Combo',
    imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=900&q=80',
    discountPercent: 10,
  }
];

const coupons = [
  {
    code: 'WELCOME10',
    description: 'Алғашқы тапсырысқа 10%',
    discountPercent: 10,
    minOrder: 2000,
  },
  {
    code: 'FREEDEL',
    description: 'Жеткізу тегін (500₸)',
    discountAmount: 500,
    minOrder: 2500,
  }
];

const menuItems = [
  {
    restaurantName: 'Dala Tastes',
    name: 'Бешбармақ bowl',
    description: 'Сиыр еті, қамыр, сорпа',
    category: 'Популярное',
    price: 3200,
    calories: 560,
    imageUrl: 'https://images.unsplash.com/photo-1604908177522-0403524c5b0b?auto=format&fit=crop&w=900&q=80',
    isPopular: true
  },
  {
    restaurantName: 'Dala Tastes',
    name: 'Қуырдақ',
    description: 'Қуырылған ет, картоп',
    category: 'Горячее',
    price: 2900,
    calories: 480,
    imageUrl: 'https://images.unsplash.com/photo-1625944230942-8d9a0f32db0c?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Dala Tastes',
    name: 'Сорпа',
    description: 'Ет қосылған ұлттық сорпа',
    category: 'Супы',
    price: 1500,
    calories: 240,
    imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Dala Tastes',
    name: 'Казы карта',
    description: 'Қақталған қазы және карта',
    category: 'Закуски',
    price: 2600,
    calories: 420,
    imageUrl: 'https://images.unsplash.com/photo-1526318896980-cf78c088247c?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Steppe Pizza',
    name: 'Маргарита',
    description: 'Томат, моцарелла, базилик',
    category: 'Пицца',
    price: 2500,
    calories: 520,
    imageUrl: 'https://images.unsplash.com/photo-1548365328-8b849e6f7c3b?auto=format&fit=crop&w=900&q=80',
    isPopular: true
  },
  {
    restaurantName: 'Steppe Pizza',
    name: 'Spicy Lamb',
    description: 'Қой еті, чили, smoked cheese',
    category: 'Пицца',
    price: 3400,
    calories: 610,
    imageUrl: 'https://images.unsplash.com/photo-1541745537411-b8046dc6d66c?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Steppe Pizza',
    name: 'Truffle Mushroom',
    description: 'Саңырауқұлақ, трюфель тұздығы',
    category: 'Пицца',
    price: 3600,
    calories: 640,
    imageUrl: 'https://images.unsplash.com/photo-1541745537411-b8046dc6d66c?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Steppe Pizza',
    name: 'Lemonade',
    description: 'Жаңа лимон, жалбыз',
    category: 'Напитки',
    price: 900,
    calories: 140,
    imageUrl: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Central Sushi',
    name: 'California roll',
    description: 'Краб, авокадо, икра',
    category: 'Суши',
    price: 3100,
    calories: 390,
    imageUrl: 'https://images.unsplash.com/photo-1553621042-f6e147245754?auto=format&fit=crop&w=900&q=80',
    isPopular: true
  },
  {
    restaurantName: 'Central Sushi',
    name: 'Salmon poke',
    description: 'Лосось, күріш, соус',
    category: 'Горячее',
    price: 3600,
    calories: 520,
    imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Central Sushi',
    name: 'Мисо суп',
    description: 'Тофу және теңіз балдырлары',
    category: 'Супы',
    price: 1200,
    calories: 180,
    imageUrl: 'https://images.unsplash.com/photo-1547592180-22c7d8a90f97?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Central Sushi',
    name: 'Dragon roll',
    description: 'Унаги, авокадо, соус унаги',
    category: 'Суши',
    price: 3600,
    calories: 420,
    imageUrl: 'https://images.unsplash.com/photo-1553621042-f6e147245754?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Bauyrdaq & Co',
    name: 'Баурсақ ассорти',
    description: 'Жылы баурсақ, бал қосылған',
    category: 'Десерт',
    price: 1400,
    calories: 380,
    imageUrl: 'https://images.unsplash.com/photo-1514516873439-d295f3b40e44?auto=format&fit=crop&w=900&q=80',
    isPopular: true
  },
  {
    restaurantName: 'Bauyrdaq & Co',
    name: 'Қаймақ бал',
    description: 'Қаймақ пен бал',
    category: 'Десерт',
    price: 900,
    calories: 260,
    imageUrl: 'https://images.unsplash.com/photo-1481391032119-d89fee407e44?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Bauyrdaq & Co',
    name: 'Cappuccino',
    description: 'Жұмсақ кофе дәмі',
    category: 'Напитки',
    price: 1000,
    calories: 120,
    imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Green Bowl',
    name: 'Avocado bowl',
    description: 'Авокадо, киноа, көкөніс',
    category: 'Healthy',
    price: 2800,
    calories: 420,
    imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80',
    isPopular: true
  },
  {
    restaurantName: 'Green Bowl',
    name: 'Chicken salad',
    description: 'Тауық еті, жасыл салат',
    category: 'Салат',
    price: 2600,
    calories: 360,
    imageUrl: 'https://images.unsplash.com/photo-1543353071-087092ec393a?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Green Bowl',
    name: 'Detox smoothie',
    description: 'Жасыл алма, қияр, шпинат',
    category: 'Напитки',
    price: 1500,
    calories: 180,
    imageUrl: 'https://images.unsplash.com/photo-1502741224143-90386d7f8c82?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Burger Caravan',
    name: 'Classic burger',
    description: 'Сиыр еті, ірімшік, соус',
    category: 'Бургер',
    price: 2900,
    calories: 680,
    imageUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=900&q=80',
    isPopular: true
  },
  {
    restaurantName: 'Burger Caravan',
    name: 'Cheese fries',
    description: 'Ірімшікпен қуырылған картоп',
    category: 'Снэк',
    price: 1600,
    calories: 520,
    imageUrl: 'https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Burger Caravan',
    name: 'Milkshake',
    description: 'Ванильді милкшейк',
    category: 'Напитки',
    price: 1400,
    calories: 410,
    imageUrl: 'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Thai Silk',
    name: 'Pad Thai',
    description: 'Күріш кеспесі, тауық еті, жаңғақ',
    category: 'Горячее',
    price: 3400,
    calories: 520,
    imageUrl: 'https://images.unsplash.com/photo-1546069901-5ec6a79120b0?auto=format&fit=crop&w=900&q=80',
    isPopular: true
  },
  {
    restaurantName: 'Thai Silk',
    name: 'Green curry',
    description: 'Көк карри, кокос сүті',
    category: 'Горячее',
    price: 3600,
    calories: 540,
    imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=900&q=80'
  },
  {
    restaurantName: 'Thai Silk',
    name: 'Tom Yum',
    description: 'Ащы қышқыл сорпа',
    category: 'Супы',
    price: 2600,
    calories: 220,
    imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=900&q=80'
  }
];

async function seed() {
  await connectDb(process.env.MONGO_URI);

  await MenuItem.deleteMany({});
  await Restaurant.deleteMany({});
  await Category.deleteMany({});
  await Promo.deleteMany({});
  await Coupon.deleteMany({});

  const createdRestaurants = await Restaurant.insertMany(restaurants);
  await Category.insertMany(categories);
  await Promo.insertMany(promos);
  await Coupon.insertMany(coupons);

  const menuDocs = menuItems.map((item) => {
    const restaurant = createdRestaurants.find((r) => r.name === item.restaurantName);
    return {
      restaurant: restaurant._id,
      name: item.name,
      description: item.description,
      category: item.category,
      price: item.price,
      calories: item.calories,
      imageUrl: item.imageUrl,
      isPopular: item.isPopular || false
    };
  });

  await MenuItem.insertMany(menuDocs);

  console.log('Seed complete');
  process.exit(0);
}

seed().catch((error) => {
  console.error('Seed failed', error);
  process.exit(1);
});
