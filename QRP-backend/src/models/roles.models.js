import mongoose from 'mongoose';

const roleSchema = new mongoose.Schema(
  {
    role_id: {
      type: Number,
      unique: true,
      required: true,
    },
    role_name: {
      type: String,
      required: true,
      enum: ['Executor', 'Reviewer', 'SDH'],
    },
    description: {
      type: String,
    },
  },
  { timestamps: true }
);

export const Role = mongoose.model("Role", roleSchema);