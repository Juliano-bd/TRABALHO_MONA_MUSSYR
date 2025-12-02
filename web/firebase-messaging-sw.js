importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
 apiKey: "AIzaSyDhmSxPftiB9IxIaTsrRTEpboIFv83Pgug",
  authDomain: "avfmonaboer.firebaseapp.com",
  projectId: "avfmonaboer",
  storageBucket: "avfmonaboer.firebasestorage.app",
  messagingSenderId: "615926358346",
  appId: "1:615926358346:web:b9f1e83f1bd6c251a2e1b3"
});

const messaging = firebase.messaging();