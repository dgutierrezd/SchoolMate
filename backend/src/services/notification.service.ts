import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    }),
  });
}

export async function sendPushNotification(
  deviceToken: string,
  title: string,
  body: string,
  data?: Record<string, string>
): Promise<void> {
  try {
    await admin.messaging().send({
      token: deviceToken,
      notification: { title, body },
      data,
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    });
  } catch (error) {
    console.error("Failed to send push notification:", error);
    throw error;
  }
}

export async function sendHomeworkReminder(
  deviceToken: string,
  childName: string,
  homeworkTitle: string,
  language: "en" | "es"
): Promise<void> {
  const title =
    language === "es" ? "📚 Tarea pendiente" : "📚 Homework Reminder";
  const body =
    language === "es"
      ? `${childName} tiene que entregar "${homeworkTitle}" mañana`
      : `${childName} has "${homeworkTitle}" due tomorrow`;

  await sendPushNotification(deviceToken, title, body, {
    type: "homework_reminder",
  });
}

export async function sendMorningSummary(
  deviceToken: string,
  childName: string,
  taskCount: number,
  language: "en" | "es"
): Promise<void> {
  const title =
    language === "es" ? "☀️ Resumen del día" : "☀️ Morning Summary";
  const body =
    language === "es"
      ? `${childName} tiene ${taskCount} tarea(s) para hoy`
      : `${childName} has ${taskCount} task(s) today`;

  await sendPushNotification(deviceToken, title, body, {
    type: "morning_summary",
  });
}

export async function sendStudyStreakReminder(
  deviceToken: string,
  childName: string,
  language: "en" | "es"
): Promise<void> {
  const title =
    language === "es" ? "🔥 ¡No pierdas tu racha!" : "🔥 Keep the streak!";
  const body =
    language === "es"
      ? `${childName} no ha estudiado hoy`
      : `${childName} hasn't studied today`;

  await sendPushNotification(deviceToken, title, body, {
    type: "study_streak",
  });
}

export async function sendWeeklyReport(
  deviceToken: string,
  childName: string,
  language: "en" | "es"
): Promise<void> {
  const title =
    language === "es" ? "📊 Reporte semanal" : "📊 Weekly Report";
  const body =
    language === "es"
      ? `El reporte semanal de ${childName} está listo`
      : `${childName}'s weekly report is ready`;

  await sendPushNotification(deviceToken, title, body, {
    type: "weekly_report",
  });
}
