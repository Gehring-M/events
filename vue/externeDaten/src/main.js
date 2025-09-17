import { createApp } from 'vue'

// ROOT COMPONENT as entry point
import Geodatenimport from './Geodatenimport.vue'

// Looking for <div id="geodatenimport">
let rootElement = document.querySelector('div#geodatenimport')

// Mount or notify user about failure
if (rootElement !== null) {
    const app = createApp(Geodatenimport)
    app.mount('#geodatenimport')
}
else {
    console.log('Not able to mount Vue-Component')
}
