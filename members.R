
#-------------------------------------------------------------------
# Purpose: Web scraping html table of US Congressmen
# Author: Tega Okene
#-------------------------------------------------------------------

rm(list = ls())

# Install pacman
if (!require("pacman")) install.packages("pacman")

# install/load packages as necessary
pacman::p_load(rvest,
               dplyr,
               stringr)

# negate %in%
"%notin%" = Negate("%in%")

# Web scraping
website_url = "https://pressgallery.house.gov/member-data/members-official-twitter-handles"
website = read_html(website_url)

tbls = html_nodes(website, "table")

tbls_ls = website %>%
  html_nodes("table") %>%
  .[1] %>%
  html_table(fill = TRUE)

# Manipulate data from the congress table
congress_tbl = tbls_ls %>%
  as.data.frame() %>%
  slice(-(1:3)) %>%
  rename(first_name = X1,
         last_name = X2,
         handle = X3,
         state_dist = X4,
         party = X5 ) %>%
  select(first_name:party)


# party info missing for @RepLCD in website
congress_tbl[which(congress_tbl$handle == "@RepLCD"), "party"] = "R"

handles_party = congress_tbl %>%
  filter(handle %notin% c("TBD", "No official", "")) %>%
  select(handle,
         party) %>%
  mutate(handle = str_sub(handle, 2, length(handle)),
         handle_party = paste0(handle," ", party)) %>%
  select(handle_party)


# Save list of member handles and party to .txt file
# in the current directory

file = paste0(getwd(), "/handles_party.txt")

handles_party$handle_party %>%
  writeLines(file)

