---
title: "From Physical Books to a Digital Library: Introducing the Book Barcode Scanner & EPUB Generator"
date: 2025-10-25
description: "A new tool to help you digitize your physical book library."
tags:
- php
- project
- books
---

My family has a lot of books collected over time and so I wanted to track all the physical books we have. Although there are a few good self-hosted physical book management out there, but none are quite as user-friendly/nice to look at as some of the ebook management applications. In particular I found [Booklore](https://github.com/booklore-app/booklore) which was close to perfect - but it couldn't handle bulk importing of physical books. There were some some references online to using placeholder epubs to represent physical books - but nothing which described how to do this (or a way to do it in bulk).

What I really wanted was a way to scan the ISBN on each book, and have something take care of looking up the details, finding the metadata and creating the placeholder on my behalf. The result of that is this app.

It's been a while since I did much php, but here it is anyway: the [Book Barcode Scanner & EPUB Generator](https://github.com/adebenham/make-placeholder-epubs). It’s a PHP-based web application that allows you to scan a book’s barcode (ISBN) using your device’s camera, fetch its metadata from various online sources, and generate a basic EPUB file.

### The Problem

If you have a large collection of physical books, you know how hard it can be to keep track of them. While there are great tools for managing ebooks, physical book management often falls short in terms of user experience. I wanted a way to quickly and easily digitize my physical library, and that's where the idea for this project was born.

### The Solution

The Book Barcode Scanner & EPUB Generator is a simple web app that streamlines the process of creating a digital record of your physical books. Here’s how it works:

1.  **Scan a Barcode:** Using your device's camera, you can scan the ISBN barcode of any book.
2.  **Fetch Metadata:** The application then fetches the book's information (title, author, description, cover image, etc.) from multiple sources, including Hardcover, Google Books, and Open Library.
3.  **Generate an EPUB:** Finally, it generates a simple EPUB file containing all the fetched metadata. This EPUB can then be imported into your favorite ebook manager, like Booklore or Calibre, creating a "placeholder" for your physical book.

![Screenshot](/posts/media/make-placeholder-epub.jpg)

### Key Features

*   **Barcode Scanning:** Scan ISBNs directly in your browser.
*   **Manual Search:** If a barcode isn't found, you can search by title and author.
*   **Gemini Vision Search:** Take a photo of the book cover, and Gemini will try to identify it.
*   **EPUB Generation:** Create `.epub` files with the fetched metadata and cover image.
*   **Web Interface:** A user-friendly interface for scanning and generating EPUBs.

### The Technical Side

The application is built with PHP and uses a few key APIs to fetch book metadata:

*   **Hardcover:** For high-quality book information.
*   **Google Books:** As a fallback for metadata.
*   **Open Library:** For additional book data.
*   **Gemini:** To power the book cover recognition feature.

### Get Started

The project is open-source and available @ https://github.com/cjd/make-placeholder-epubs/. To get started, you'll need a PHP environment and API keys for Hardcover and Gemini. You can find detailed setup instructions in the [README.md](https://github.com/cjd/make-placeholder-epubs/blob/main/README.md) file.

I hope this project helps others who are looking for a better way to manage their physical book collections.
