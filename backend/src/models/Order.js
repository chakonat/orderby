const mongoose = require('mongoose');

const OrderItemSchema = new mongoose.Schema(
  {
    menuItem: { type: mongoose.Schema.Types.ObjectId, ref: 'MenuItem', required: true },
    name: { type: String, required: true },
    price: { type: Number, required: true, min: 0 },
    quantity: { type: Number, required: true, min: 1 }
  },
  { _id: false }
);

const OrderSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    restaurant: { type: mongoose.Schema.Types.ObjectId, ref: 'Restaurant', required: true },
    items: { type: [OrderItemSchema], required: true },
    subtotal: { type: Number, required: true, min: 0 },
    deliveryFee: { type: Number, required: true, min: 0 },
    discount: { type: Number, default: 0 },
    total: { type: Number, required: true, min: 0 },
    couponCode: { type: String, default: '' },
    status: {
      type: String,
      enum: ['created', 'paid', 'preparing', 'delivering', 'completed', 'cancelled'],
      default: 'created'
    },
    paymentMethod: {
      type: String,
      enum: ['card', 'kaspi', 'apple_pay', 'google_pay', 'cash'],
      required: true
    },
    paymentStatus: {
      type: String,
      enum: ['pending', 'paid', 'failed'],
      default: 'pending'
    },
    customer: {
      name: { type: String, required: true, trim: true },
      phone: { type: String, required: true, trim: true },
      address: { type: String, required: true, trim: true }
    }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Order', OrderSchema);
