# Load necessary libraries


library(sf)
library(ggmap)
library(ggplot2)
library(dplyr)
library(ggpubr)
library(ggsci)

# Load the fire incident data
# Replace 'your_file_path.xlsx' with the path to your Excel file
library(readxl)
fire_data <- read_excel('/Users/junrunchen/Desktop/dissertation/London_Fire_Events_with_Features_Detailed.xlsx', sheet = 'Sheet1')

# Filter out rows with missing coordinates
fire_data <- fire_data %>% filter(!is.na(Latitude) & !is.na(Longitude))

# Convert to an sf object
fire_data_sf <- st_as_sf(fire_data, coords = c("Longitude", "Latitude"), crs = 4326)

# Define the bounding box for Greater London (approximate coordinates)
bbox <- st_bbox(c(xmin = -0.5103751, xmax = 0.3340155, ymin = 51.2867602, ymax = 51.6918741), crs = st_crs(4326))

# Get the base map tiles for Greater London
base_map <- get_stamenmap(bbox = bbox, maptype = "terrain", color = "bw", crop = FALSE, zoom = 10)

# Generate the heatmap
heatmap <- ggmap(base_map) +
  stat_density2d(data = fire_data_sf, aes(x = st_coordinates(.)[,1], y = st_coordinates(.)[,2], fill = ..level.., alpha = ..level..), 
                 geom = "polygon", color = "white") +
  scale_fill_distiller(palette = 'YlOrRd', trans = "reverse") +
  scale_alpha(range = c(0.20, 0.40), guide = FALSE) +
  labs(x = NULL, y = NULL, fill = "Relative\nDensity") +
  theme_minimal() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

# Display the heatmap
print(heatmap)

# Save the heatmap to a file
ggsave("Greater_London_Fire_Heatmap.png", plot = heatmap, width = 10, height = 10, units = "in", dpi = 300)
