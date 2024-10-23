---
title: "Search" # in any language you want
layout: "search" # necessary for search
summary: "Search"
url: "/search/"
placeholder: "placeholder text in search input box"
menu:
  main:
    name: Search
    weight: 1000
---

<link href="/pagefind/pagefind-ui.css" rel="stylesheet">
<script src="/pagefind/pagefind-ui.js"></script>
<div id="search"></div>
<script>
  const queryString = window.location.search;
  const urlParams = new URLSearchParams(queryString);
  const searchString = urlParams.get("q");
  // initialize Pagefind UI
  window.addEventListener('DOMContentLoaded', (event) => {
    let pagefind = new PagefindUI({ element: "#search" });
    if (searchString) {
      pagefind.triggerSearch(searchString);
    }
  });
  // setting the focus into the generated INPUT field as it appears
  waitForElm(".pagefind-ui__search-input").then((elm) => {
    elm.focus();
  });
</script>
