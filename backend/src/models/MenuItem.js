const mongoose = require('mongoose');

const MenuItemSchema = new mongoose.Schema(
  {
    restaurant: { type: mongoose.Schema.Types.ObjectId, ref: 'Restaurant', required: true },
    name: { type: String, required: true, trim: true },
    description: { type: String, default: '' },
    category: { type: String, default: 'Популярное' },
    price: { type: Number, required: true, min: 0 },
    calories: { type: Number, default: 0 },
    imageUrl: { type: String, default: '' },
    isPopular: { type: Boolean, default: false },
    isAvailable: { type: Boolean, default: true }
  },
  { timestamps: true }
);

module.exports = mongoose.model('MenuItem', MenuItemSchema);
