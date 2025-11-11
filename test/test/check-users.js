// Check if users exist in database
require('dotenv').config();
const mongoose = require('mongoose');
const databaseConfig = require('../config/database.config');

async function checkUsers() {
    try {
        await databaseConfig.connect();
        
        const User = require('../models/User.model');
        
        const tigist = await User.findOne({ firebaseUid: '09a08a5d-fd36-46c0-8974-8ce8489931f9' });
        const abel = await User.findOne({ firebaseUid: 'ba98ae1c-86c9-4f9e-b9d6-452167334489' });
        
        console.log('\n👤 User 1 (tigist):');
        if (tigist) {
            console.log('  MongoDB ID:', tigist._id.toString());
            console.log('  Firebase UID:', tigist.firebaseUid);
            console.log('  Username:', tigist.username);
            console.log('  Email:', tigist.email);
        } else {
            console.log('  ❌ Not found in database');
        }
        
        console.log('\n👤 User 2 (abel):');
        if (abel) {
            console.log('  MongoDB ID:', abel._id.toString());
            console.log('  Firebase UID:', abel.firebaseUid);
            console.log('  Username:', abel.username);
            console.log('  Email:', abel.email);
        } else {
            console.log('  ❌ Not found in database');
        }
        
        console.log('\n📊 Summary:');
        console.log('  Tigist exists:', tigist ? '✅ YES' : '❌ NO');
        console.log('  Abel exists:', abel ? '✅ YES' : '❌ NO');
        if (tigist && abel) {
            console.log('  Same MongoDB ID?', tigist._id.toString() === abel._id.toString() ? '❌ YES (PROBLEM!)' : '✅ NO');
        }
        
        await databaseConfig.disconnect();
        process.exit(0);
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
}

checkUsers();
