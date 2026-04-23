const CACHE = 'arabobase-v1';

const ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
  '/audio/alif.mp3',
  '/audio/ba.mp3',
  '/audio/ta.mp3',
  '/audio/tha.mp3',
  '/audio/jim.mp3',
  '/audio/hha.mp3',
  '/audio/kha.mp3',
  '/audio/dal.mp3',
  '/audio/dhal.mp3',
  '/audio/ra.mp3',
  '/audio/zay.mp3',
  '/audio/sin.mp3',
  '/audio/shin.mp3',
  '/audio/sad.mp3',
  '/audio/dad.mp3',
  '/audio/taa.mp3',
  '/audio/zaa.mp3',
  '/audio/ayn.mp3',
  '/audio/ghayn.mp3',
  '/audio/fa.mp3',
  '/audio/qaf.mp3',
  '/audio/kaf.mp3',
  '/audio/lam.mp3',
  '/audio/mim.mp3',
  '/audio/nun.mp3',
  '/audio/ha.mp3',
  '/audio/waw.mp3',
  '/audio/ya.mp3',
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  e.respondWith(
    caches.match(e.request).then(cached => cached || fetch(e.request))
  );
});
