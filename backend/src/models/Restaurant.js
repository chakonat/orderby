const mongoose = require('mongoose');

const RestaurantSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    description: { type: String, default: '' },
    cuisine: { type: String, default: '' },
    imageUrl: { type: String, default: '' },
    city: { type: String, default: '' },
    rating: { type: Number, default: 4.5 },
    priceLevel: { type: String, default: '₸₸' },
    deliveryTime: { type: String, default: '25-35 мин' },
    minOrder: { type: Number, default: 1500 },
    deliveryFee: { type: Number, default: 0 },
    tags: { type: [String], default: [] },
    isActive: { type: Boolean, default: true }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Restaurant', RestaurantSchema);
