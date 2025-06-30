# ArtProvenance - Digital Art Provenance System

A blockchain-based digital art provenance and authenticity verification system built on Stacks, providing immutable records of digital artwork creation and authentication.

## Overview

ArtProvenance enables digital artists to register their creations with verifiable provenance while allowing authorized curators to authenticate artworks, establishing trust and preventing fraud in the digital art market.

## Features

- Digital artwork registration with creation timestamps
- Art curator authorization and authentication workflow
- Immutable provenance tracking and verification
- Creation details and medium type documentation
- Artist portfolio management and organization

## Smart Contract Functions

### Public Functions
- `register-art-curator`: Register authorized art curators
- `register-digital-artwork`: Register new digital artworks
- `authenticate-digital-artwork`: Authenticate artworks by authorized curators

### Read-Only Functions
- `get-digital-artwork`: Retrieve artwork information
- `get-artist-portfolio`: Get artist's artwork portfolio
- `is-art-curator`: Check curator authorization status

## Usage

Deploy the contract with a gallery director account. Register art curators, then artists can register their digital artworks for authentication by authorized curators.

## Security

- Gallery director access control for curator registration
- Comprehensive input validation and timestamp verification
- Principal validation to prevent unauthorized access
- Portfolio capacity limits for system performance