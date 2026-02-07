const mongoose = require('mongoose');

const AddressSchema = new mongoose.Schema(
  {
    label: { type: String, default: '' },
    city: { type: String, default: '' },
    street: { type: String, required: true },
    building: { type: String, required: true },
    apartment: { type: String, default: '' },
    comment: { type: String, default: '' },
    isDefault: { type: Boolean, default: false }
  },
  { _id: true }
);

const UserSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    phone: { type: String, required: true, unique: true, trim: true },
    email: { type: String, default: '', trim: true },
    passwordHash: { type: String, required: true },
    addresses: { type: [AddressSchema], default: [] }
  },
  { timestamps: true }
);

module.exports = mongoose.model('User', UserSchema);
