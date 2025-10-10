import { User } from "../models/user.models.js";
import { Role } from "../models/roles.models.js";

export const seedAdmin = async () => {
  const adminEmail = "admin@gmail.com";
  const adminPassword = "adminadmin";
  const adminName = "Admin";
  const adminRole = await Role.findOne({ role_name: "SDH" });

  if (!adminRole) {
    console.log("SDH role not found. Run seedRoles first.");
    return;
  }

  const exists = await User.findOne({ email: adminEmail });
  if (!exists) {
    await User.create({
      name: adminName,
      email: adminEmail,
      password: adminPassword,
      role: adminRole._id,
    });
    console.log(`✅ Admin user '${adminEmail}' created`);
  } else {
    console.log(`ℹ️ Admin user '${adminEmail}' already exists`);
  }
};
