import { sql } from '@vercel/postgres';

export default async function handler(request, response) {
  // Support both GET and POST
  const deviceId = request.query.deviceId || request.body?.deviceId;

  if (!deviceId) {
    return response.status(400).json({ error: 'deviceId is required' });
  }

  try {
    // Check if the device exists in the users table
    const { rows } = await sql`SELECT device_id, trial_start_date, is_paid FROM users WHERE device_id = ${deviceId};`;
    
    if (rows.length === 0) {
      // If the ID is new: Insert it with the current date as trial_start_date
      await sql`
        INSERT INTO users (device_id, trial_start_date, is_paid)
        VALUES (${deviceId}, CURRENT_TIMESTAMP, FALSE);
      `;

      return response.status(200).json({
        status: "trial",
        days_left: 7
      });
    }

    const user = rows[0];

    // If already paid, status is active
    if (user.is_paid) {
      return response.status(200).json({
        status: "active",
        days_left: 999 
      });
    }

    // Calculate trial expiration (7 days)
    const trialStartDate = new Date(user.trial_start_date);
    const now = new Date();
    
    // Difference in milliseconds
    const diffInMs = now.getTime() - trialStartDate.getTime();
    // Convert to days (rounding down to see how many FULL days have passed)
    const daysPassed = Math.floor(diffInMs / (1000 * 60 * 60 * 24));
    
    const daysLeft = 7 - daysPassed;

    if (daysLeft > 0) {
      return response.status(200).json({
        status: "trial",
        days_left: daysLeft
      });
    } else {
      return response.status(200).json({
        status: "expired",
        days_left: 0
      });
    }

  } catch (error) {
    console.error('API Error:', error);
    return response.status(500).json({ 
      error: "Internal Server Error", 
      message: error.message 
    });
  }
}
