;; Emacs Config

(global-set-key (kbd "C-S-c") 'kill-ring-save)

;; Disable the menu bar
(menu-bar-mode -1)

;; Disable backup files
(setq make-backup-files nil)
(setq backup-director-alist '(("." . "~/.emacs_saves")))

;; Set meta key to the super key
(setq x-meta-keysym 'ESC)

;; Disable the startup screen
(setq inhibit-startup-screen t)

;; Install and configure packages
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package smex
  :bind (("M-x" . smex)
         ("M-X" . smex-major-mode-commands)))
;; Dark theme
(use-package modus-themes
  :ensure t
  :init
  (load-theme 'modus-vivendi-deuteranopia t))

(use-package ido
  :init (ido-mode 1))

;; Set cursor type to bar
(setq-default cursor-type 'bar)

;; Customize variables
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(abyss))
 '(custom-safe-themes
   '("1e2f562077d76160ad2a4b648bf754698ab8cdf3914db933badc356881dad147" "ffef467dfed832df46d4e188049e52aad1d64c16070484fc6b62f158ece95471" "33876ef6caf9c4cb35f8bc9430fb64ba503036a4e80532bb764edec121900248" "e4013fb0675182b04aa22f29054842db418d5a72da7ebb3c5b9dbb624502aaec" "f48be80177f0d9a2b19d8dc19f3903d9be3c4d885d110e82b591d1184586fad0" "46c65f6d9031e2f55b919b1486952cddcc8e3ee081ade7eb2ffb6a68a804d30e" "72cc2c6c5642b117034b99dcc3a33ff97a66593429c7f44cd21b995b17eebd4e" "c2efe6f5e2bd0bddfb2d6e26040545768939d2029f77e6b6a18d1ee0e0cb1033" "6a94122cfa72865c9b7a211ee461e4cc8834451d035fb43ffa478a630dec3d5b" "dbc6d947d551aa03090daf6256233454c6a63240e17a8f3d77889d76fef1749d" "3d4df186126c347e002c8366d32016948068d2e9198c496093a96775cc3b3eaa" "bc6a96def5282e9d8a07edc03e02697eae9ab2e21a90ed2f07038bbf6ed4145c" "306d853c5b47e1baf5e815eb49daa8a46d7f54d3f5ab624f3b30a6c1eb8e1f0c" "2a7d6f6a46b1b8504b269029a7375597f208a5cdfa1ea125b09255a592bb326e" "74367676a7b0562975704f8e576d5e103451527b36c9226a013cd8f3ae2140f5" "e16cd3e6093cf35e65dbac6c7649931936f32f56be34477cb7cbe1ee332c5b99" "a9c9f34794fa0b2da9e111a85402fb3f9b82e281398e0249bbc073210592e198" "2da5f695ab1373fd25e06302a3055eac39c37e6962063eb87c2e0a6e2d6ef5c0" "75e027e3ab2892c5c1f152e3d9fae03718f75bee50d259040e56e7e7672a4872" default))
 '(package-selected-packages
   '(lin popup-imenu popup-complete ef-themes abyss-theme modus-themes smex use-package)))

;; Customize faces
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;;
(require 'popup)
(set-face-background 'popup-face "#444444")
