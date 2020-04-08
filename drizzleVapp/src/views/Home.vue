<template>
  <div class="home">
    <img alt="Vue logo" src="../assets/logo.png" />
    <HelloWorld msg="Welcome to Your Vue.js App" />
  </div>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  name: 'Login Test',
  computed: mapGetters('drizzle', ['isDrizzleInitialized'])
}
</script>
