import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { User } from "../models/user.models.js";
import { Role } from "../models/roles.models.js";
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt"


const registerUser = asyncHandler(async (req, res) => {
  const { name, email, password, role_name } = req.body;

  // Validate required fields
  if ([name, email, password].some((f) => !f?.trim())) {
    throw new ApiError(400, "All fields are required");
  }

  // Check if user exists
  const existingUser = await User.findOne({ email });
  if (existingUser) {
    throw new ApiError(409, "User already exists with this email");
  }

  // Get role reference
  const role =
    (await Role.findOne({ role_name })) ||
    (await Role.findOne({ role_name: "Executor" })); // default role

  if (!role) throw new ApiError(400, "Invalid or missing role");

  
const user = await User.create({
    name,
    email,
    password,
    role: role._id,
  });
  

  const createdUser = await User.findById(user._id)
    .populate("role")
    .select("-password -accessToken");
    if(!createdUser){
        throw new ApiError(500,"something wnet wrong while registering user")
    }

  return res
    .status(201)
    .json(new ApiResponse(201, createdUser, "User registered successfully"));
});


const loginUser = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    throw new ApiError(400, "Email and password are required");
  }

  const user = await User.findOne({ email }).populate("role");
  if (!user) throw new ApiError(404, "User not found");

  const isPasswordValid = await user.isPasswordCorrect(password);
  if (!isPasswordValid) throw new ApiError(404, "Invalid credentials");

  // Generate new token and save (invalidate previous)
  const accessToken = user.generateAccessToken(user._id);
  user.accessToken = accessToken;
await user.save();

  

 const options={
        httpOnly:true,
        secure:false
    }


  const loggedUser = await User.findById(user._id)
    .populate("role")
    .select("-password -accessToken");

  return res
    .status(200)
    .cookie("token",accessToken,options)
    .json(new ApiResponse(200, loggedUser, "User logged in successfully"));
});


const logoutUser = asyncHandler(async (req, res) => {
  const userId = req.user?._id;

  if (!userId) throw new ApiError(401, "Unauthorized");

  await User.findByIdAndUpdate(userId, { accessToken: null });

  const options={
        httpOnly:true,
        secure:false
    }

  return res
    .status(200)
    .clearCookie("token",options)
    .json(new ApiResponse(200, {}, "User logged out successfully"));
});

export { registerUser, loginUser, logoutUser };


