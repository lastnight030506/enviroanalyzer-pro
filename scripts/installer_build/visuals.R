# ============================================================================ #
#                     VISUALS.R - TRỰC QUAN HÓA DỮ LIỆU MÔI TRƯỜNG             #
# ============================================================================ #
# Tác giả: Environmental Engineering Student
# Mô tả: Các hàm tạo biểu đồ và bảng dữ liệu (gt tables, ggplot2, Radar, Gauge)
# ============================================================================ #

library(ggplot2)
library(scales)
library(gt)

# ---- 1. THEME CHO BIỂU ĐỒ ----

#' Theme môi trường tùy chỉnh cho ggplot2
#' @param base_size Kích thước font cơ bản
#' @param accent_color Màu nhấn chính
#' @param dark_mode Chế độ tối
#' @return ggplot2 theme
theme_environmental <- function(base_size = 12, accent_color = "#1565C0", dark_mode = FALSE) {
  if (dark_mode) {
    bg_color <- "#1e1e1e"
    text_color <- "#e0e0e0"
    grid_color <- "#333333"
    panel_bg <- "#2d2d2d"
  } else {
    bg_color <- "#ffffff"
    text_color <- "#333333"
    grid_color <- "#e0e0e0"
    panel_bg <- "#fafafa"
  }
  
  theme_minimal(base_size = base_size) +
    theme(
      # Text
      text = element_text(family = "Roboto", color = text_color),
      plot.title = element_text(size = base_size * 1.4, face = "bold", 
                                 color = accent_color, margin = margin(b = 10)),
      plot.subtitle = element_text(size = base_size * 0.9, color = text_color,
                                    margin = margin(b = 15)),
      plot.caption = element_text(size = base_size * 0.7, color = text_color,
                                   hjust = 1, margin = margin(t = 10)),
      
      # Axes
      axis.title = element_text(size = base_size * 0.9, face = "bold"),
      axis.text = element_text(size = base_size * 0.8, color = text_color),
      axis.line = element_line(color = grid_color, linewidth = 0.5),
      
      # Panel
      panel.background = element_rect(fill = panel_bg, color = NA),
      panel.grid.major = element_line(color = grid_color, linewidth = 0.3),
      panel.grid.minor = element_blank(),
      
      # Legend
      legend.position = "bottom",
      legend.background = element_rect(fill = bg_color, color = NA),
      legend.title = element_text(face = "bold", size = base_size * 0.9),
      legend.text = element_text(size = base_size * 0.8),
      
      # Plot background
      plot.background = element_rect(fill = bg_color, color = NA),
      plot.margin = margin(15, 15, 15, 15)
    )
}

# ---- 2. BIỂU ĐỒ RADAR (SPIDER CHART) ----

#' Tạo biểu đồ Radar cho so sánh các thông số
#' @param data Data frame với cột Parameter, Value, Limit
#' @param title Tiêu đề biểu đồ
#' @param accent_color Màu nhấn
#' @param dark_mode Chế độ tối
#' @return ggplot object
create_radar_chart <- function(data, title = "So sánh với ngưỡng QCVN",
                                accent_color = "#1565C0", dark_mode = FALSE) {
  
  if (is.null(data) || nrow(data) == 0) return(NULL)
  
  # Chuẩn hóa dữ liệu về % của ngưỡng
  radar_data <- data %>%
    filter(!is.na(Percent_of_Limit)) %>%
    mutate(
      Percent = pmin(Percent_of_Limit, 200),  # Giới hạn 200%
      Parameter = factor(Parameter, levels = Parameter),
      Status_Color = case_when(
        Percent_of_Limit >= 100 ~ "#C62828",
        Percent_of_Limit >= 80 ~ "#F57C00",
        TRUE ~ "#2E7D32"
      )
    )
  
  if (nrow(radar_data) < 3) {
    return(
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, label = "Cần ít nhất 3 thông số để vẽ Radar", 
                 size = 5, color = "gray50") +
        theme_void()
    )
  }
  
  n_params <- nrow(radar_data)
  
  # Tính góc cho mỗi thông số
  radar_data$angle <- seq(0, 2 * pi * (1 - 1/n_params), length.out = n_params)
  radar_data$x <- radar_data$Percent * cos(radar_data$angle)
  radar_data$y <- radar_data$Percent * sin(radar_data$angle)
  
  # Tạo lưới đồng tâm
  grid_levels <- c(25, 50, 75, 100, 150, 200)
  
  # Tạo dữ liệu cho các đường tròn lưới
  grid_data <- expand.grid(
    level = grid_levels,
    angle = seq(0, 2*pi, length.out = 100)
  ) %>%
    mutate(
      x = level * cos(angle),
      y = level * sin(angle)
    )
  
  # Tạo dữ liệu cho các đường trục
  axis_data <- data.frame(
    angle = radar_data$angle,
    x_end = 200 * cos(radar_data$angle),
    y_end = 200 * sin(radar_data$angle),
    label = radar_data$Parameter,
    label_x = 220 * cos(radar_data$angle),
    label_y = 220 * sin(radar_data$angle)
  )
  
  # Colors
  if (dark_mode) {
    bg_color <- "#1e1e1e"
    text_color <- "#e0e0e0"
    grid_color <- "#444444"
  } else {
    bg_color <- "#ffffff"
    text_color <- "#333333"
    grid_color <- "#cccccc"
  }
  
  p <- ggplot() +
    # Lưới đồng tâm
    geom_path(data = grid_data, aes(x = x, y = y, group = level),
              color = grid_color, linewidth = 0.3, linetype = "dashed") +
    # Đường ngưỡng 100%
    geom_path(data = grid_data %>% filter(level == 100), 
              aes(x = x, y = y), color = "#C62828", linewidth = 1) +
    # Đường trục
    geom_segment(data = axis_data, 
                 aes(x = 0, y = 0, xend = x_end, yend = y_end),
                 color = grid_color, linewidth = 0.3) +
    # Polygon dữ liệu
    geom_polygon(data = radar_data, aes(x = x, y = y),
                 fill = alpha(accent_color, 0.3), color = accent_color, linewidth = 1.5) +
    # Điểm dữ liệu
    geom_point(data = radar_data, aes(x = x, y = y, color = Status_Color),
               size = 4) +
    scale_color_identity() +
    # Labels
    geom_text(data = axis_data, aes(x = label_x, y = label_y, label = label),
              size = 3.5, color = text_color, fontface = "bold") +
    # Annotations
    annotate("text", x = 0, y = -230, label = "100% = Ngưỡng QCVN",
             size = 3, color = "#C62828", fontface = "italic") +
    coord_fixed() +
    labs(title = title) +
    theme_void() +
    theme(
      plot.background = element_rect(fill = bg_color, color = NA),
      plot.title = element_text(size = 14, face = "bold", color = accent_color,
                                 hjust = 0.5, margin = margin(b = 20)),
      plot.margin = margin(20, 20, 20, 20)
    )
  
  return(p)
}

# ---- 3. BIỂU ĐỒ GAUGE ----

#' Tạo biểu đồ Gauge cho một thông số
#' @param value Giá trị hiện tại (% của ngưỡng)
#' @param label Tên thông số
#' @param accent_color Màu nhấn
#' @param dark_mode Chế độ tối
#' @return ggplot object
create_gauge_chart <- function(value, label = "Compliance", 
                                accent_color = "#1565C0", dark_mode = FALSE) {
  
  if (is.na(value)) value <- 0
  value <- min(max(value, 0), 150)  # Giới hạn 0-150%
  
  # Xác định màu dựa trên giá trị
  if (value >= 100) {
    gauge_color <- "#C62828"  # Đỏ - vượt ngưỡng
    status <- "Không đạt"
  } else if (value >= 80) {
    gauge_color <- "#F57C00"  # Cam - cảnh báo
    status <- "Cảnh báo"
  } else {
    gauge_color <- "#2E7D32"  # Xanh - an toàn
    status <- "Đạt"
  }
  
  if (dark_mode) {
    bg_color <- "#1e1e1e"
    text_color <- "#e0e0e0"
    track_color <- "#444444"
  } else {
    bg_color <- "#ffffff"
    text_color <- "#333333"
    track_color <- "#e0e0e0"
  }
  
  # Tạo dữ liệu cho gauge
  # Gauge từ -135 độ đến 135 độ (270 độ total)
  start_angle <- -135 * pi / 180
  end_angle <- 135 * pi / 180
  total_angle <- end_angle - start_angle
  
  # Track (nền)
  track_angles <- seq(start_angle, end_angle, length.out = 100)
  track_data <- data.frame(
    x = cos(track_angles),
    y = sin(track_angles)
  )
  
  # Value arc
  value_angle <- start_angle + (value / 150) * total_angle
  value_angles <- seq(start_angle, value_angle, length.out = 50)
  value_data <- data.frame(
    x = cos(value_angles),
    y = sin(value_angles)
  )
  
  # Needle
  needle_angle <- value_angle
  needle_data <- data.frame(
    x = c(0, 0.7 * cos(needle_angle)),
    y = c(0, 0.7 * sin(needle_angle))
  )
  
  # Tick marks
  tick_values <- c(0, 25, 50, 75, 100, 125, 150)
  tick_angles <- start_angle + (tick_values / 150) * total_angle
  tick_data <- data.frame(
    value = tick_values,
    angle = tick_angles,
    x_inner = 0.85 * cos(tick_angles),
    y_inner = 0.85 * sin(tick_angles),
    x_outer = 1.0 * cos(tick_angles),
    y_outer = 1.0 * sin(tick_angles),
    x_label = 1.15 * cos(tick_angles),
    y_label = 1.15 * sin(tick_angles)
  )
  
  p <- ggplot() +
    # Track
    geom_path(data = track_data, aes(x = x, y = y), 
              color = track_color, linewidth = 15, lineend = "round") +
    # Value arc
    geom_path(data = value_data, aes(x = x, y = y),
              color = gauge_color, linewidth = 15, lineend = "round") +
    # Tick marks
    geom_segment(data = tick_data,
                 aes(x = x_inner, y = y_inner, xend = x_outer, yend = y_outer),
                 color = text_color, linewidth = 1) +
    # Tick labels
    geom_text(data = tick_data, aes(x = x_label, y = y_label, label = value),
              size = 3, color = text_color) +
    # Needle
    geom_segment(data = needle_data, aes(x = x[1], y = y[1], xend = x[2], yend = y[2]),
                 color = text_color, linewidth = 2, arrow = arrow(length = unit(0.3, "cm"))) +
    # Center circle
    geom_point(aes(x = 0, y = 0), size = 8, color = text_color) +
    geom_point(aes(x = 0, y = 0), size = 5, color = bg_color) +
    # Value text
    annotate("text", x = 0, y = -0.3, label = paste0(round(value, 1), "%"),
             size = 8, fontface = "bold", color = gauge_color) +
    # Status
    annotate("text", x = 0, y = -0.55, label = status,
             size = 4, color = gauge_color) +
    # Label
    annotate("text", x = 0, y = 0.5, label = label,
             size = 5, fontface = "bold", color = text_color) +
    coord_fixed(xlim = c(-1.5, 1.5), ylim = c(-1, 1.5)) +
    theme_void() +
    theme(
      plot.background = element_rect(fill = bg_color, color = NA),
      plot.margin = margin(10, 10, 10, 10)
    )
  
  return(p)
}

# ---- 4. BIỂU ĐỒ SO SÁNH NGANG ----

#' Tạo biểu đồ thanh ngang so sánh với ngưỡng
#' @param data Data frame với cột Parameter, Mean_Value, Threshold, Status
#' @param title Tiêu đề
#' @param accent_color Màu nhấn
#' @param dark_mode Chế độ tối
#' @return ggplot object
create_comparison_bar_chart <- function(data, title = "So sánh với ngưỡng QCVN",
                                         accent_color = "#1565C0", dark_mode = FALSE) {
  
  if (is.null(data) || nrow(data) == 0) return(NULL)
  
  plot_data <- data %>%
    filter(!is.na(Percent_of_Limit)) %>%
    mutate(
      Parameter = factor(Parameter, levels = rev(Parameter)),
      Percent = pmin(Percent_of_Limit, 200),
      Fill_Color = case_when(
        Percent_of_Limit >= 100 ~ "#C62828",
        Percent_of_Limit >= 80 ~ "#F57C00",
        TRUE ~ "#2E7D32"
      ),
      Label = paste0(round(Percent_of_Limit, 1), "%")
    )
  
  p <- ggplot(plot_data, aes(x = Parameter, y = Percent, fill = Fill_Color)) +
    geom_col(width = 0.7, show.legend = FALSE) +
    geom_hline(yintercept = 100, color = "#C62828", linewidth = 1, linetype = "dashed") +
    geom_text(aes(label = Label), hjust = -0.1, size = 3.5, fontface = "bold") +
    scale_fill_identity() +
    scale_y_continuous(expand = expansion(mult = c(0, 0.15)),
                       breaks = c(0, 25, 50, 75, 100, 150, 200)) +
    coord_flip() +
    labs(
      title = title,
      subtitle = "Đường đỏ: Ngưỡng QCVN (100%)",
      x = NULL,
      y = "% so với ngưỡng"
    ) +
    theme_environmental(accent_color = accent_color, dark_mode = dark_mode)
  
  return(p)
}

# ---- 5. BIỂU ĐỒ HEATMAP ----

#' Tạo biểu đồ heatmap cho nhiều mẫu
#' @param data Data frame với cột Parameter và các cột Sample_X
#' @param title Tiêu đề
#' @param accent_color Màu nhấn
#' @param dark_mode Chế độ tối
#' @return ggplot object
create_heatmap_chart <- function(data, title = "Phân bố giá trị theo mẫu",
                                  accent_color = "#1565C0", dark_mode = FALSE) {
  
  if (is.null(data) || nrow(data) == 0) return(NULL)
  
  sample_cols <- grep("^Sample_", names(data), value = TRUE)
  
  if (length(sample_cols) == 0) return(NULL)
  
  # Reshape dữ liệu
  heatmap_data <- data %>%
    select(Parameter, Percent_of_Limit, all_of(sample_cols)) %>%
    pivot_longer(cols = all_of(sample_cols), 
                 names_to = "Sample", values_to = "Value") %>%
    filter(!is.na(Value)) %>%
    left_join(
      data %>% select(Parameter, Threshold, Threshold_Type),
      by = "Parameter"
    ) %>%
    mutate(
      # Tính % cho từng mẫu riêng
      Percent = case_when(
        is.na(Threshold) ~ NA_real_,
        TRUE ~ suppressWarnings(as.numeric(gsub(" - .*", "", Threshold))) %>%
          {Value / . * 100}
      ),
      Sample = gsub("Sample_", "Mẫu ", Sample)
    )
  
  p <- ggplot(heatmap_data, aes(x = Sample, y = Parameter, fill = Percent)) +
    geom_tile(color = "white", linewidth = 0.5) +
    geom_text(aes(label = round(Value, 2)), size = 3, color = "black") +
    scale_fill_gradient2(
      low = "#2E7D32", 
      mid = "#F57C00", 
      high = "#C62828",
      midpoint = 100,
      na.value = "gray80",
      name = "% Ngưỡng"
    ) +
    labs(
      title = title,
      x = NULL,
      y = NULL
    ) +
    theme_environmental(accent_color = accent_color, dark_mode = dark_mode) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      panel.grid = element_blank()
    )
  
  return(p)
}

# ---- 6. BẢNG GT ----

#' Tạo bảng GT chuyên nghiệp cho kết quả đánh giá
#' @param data Data frame kết quả đánh giá
#' @param title Tiêu đề
#' @param accent_color Màu nhấn
#' @return gt object
create_compliance_gt_table <- function(data, title = "Kết quả đánh giá tuân thủ QCVN",
                                        accent_color = "#1565C0") {
  
  if (is.null(data) || nrow(data) == 0) return(NULL)
  
  # Verify required columns exist

  required_cols <- c("Parameter", "Unit", "Threshold", "Mean_Value", 
                     "Min_Value", "Max_Value", "Percent_of_Limit", "Status")
  if (!all(required_cols %in% names(data))) {
    return(NULL)
  }
  
  table_data <- data %>%
    select(
      `Thông số` = Parameter,
      `Đơn vị` = Unit,
      `Ngưỡng` = Threshold,
      `Giá trị TB` = Mean_Value,
      `Min` = Min_Value,
      `Max` = Max_Value,
      `% Ngưỡng` = Percent_of_Limit,
      `Trạng thái` = Status
    )
  
  gt_table <- table_data %>%
    gt() %>%
    tab_header(
      title = md(paste0("**", title, "**")),
      subtitle = md(paste0("*Ngày: ", format(Sys.time(), "%d/%m/%Y %H:%M"), "*"))
    ) %>%
    fmt_number(
      columns = c(`Giá trị TB`, Min, Max),
      decimals = 3
    ) %>%
    fmt_number(
      columns = `% Ngưỡng`,
      decimals = 1,
      pattern = "{x}%"
    ) %>%
    # Màu theo trạng thái
    tab_style(
      style = list(
        cell_fill(color = "#d4edda"),
        cell_text(color = "#155724", weight = "bold")
      ),
      locations = cells_body(
        columns = `Trạng thái`,
        rows = `Trạng thái` == "Đạt"
      )
    ) %>%
    tab_style(
      style = list(
        cell_fill(color = "#fff3cd"),
        cell_text(color = "#856404", weight = "bold")
      ),
      locations = cells_body(
        columns = `Trạng thái`,
        rows = `Trạng thái` == "Cảnh báo"
      )
    ) %>%
    tab_style(
      style = list(
        cell_fill(color = "#f8d7da"),
        cell_text(color = "#721c24", weight = "bold")
      ),
      locations = cells_body(
        columns = `Trạng thái`,
        rows = `Trạng thái` == "Không đạt"
      )
    ) %>%
    # Header styling
    tab_style(
      style = list(
        cell_fill(color = accent_color),
        cell_text(color = "white", weight = "bold")
      ),
      locations = cells_column_labels()
    ) %>%
    # General styling
    tab_options(
      table.font.size = px(12),
      heading.title.font.size = px(16),
      heading.subtitle.font.size = px(12),
      heading.background.color = accent_color,
      table.border.top.color = accent_color,
      table.border.bottom.color = accent_color,
      column_labels.border.bottom.color = accent_color
    )
  
  return(gt_table)
}

# ---- 7. BIỂU ĐỒ TRÒN TỔNG HỢP ----

#' Tạo biểu đồ tròn tổng hợp trạng thái
#' @param stats List thống kê từ calculate_compliance_stats()
#' @param title Tiêu đề
#' @param dark_mode Chế độ tối
#' @return ggplot object
create_summary_pie_chart <- function(stats, title = "Tổng hợp trạng thái tuân thủ",
                                      dark_mode = FALSE) {
  
  if (is.null(stats)) return(NULL)
  
  pie_data <- data.frame(
    Status = c("Đạt", "Cảnh báo", "Không đạt", "Không có dữ liệu"),
    Count = c(stats$compliant, stats$warning, stats$non_compliant, stats$no_data),
    Color = c("#2E7D32", "#F57C00", "#C62828", "#9E9E9E")
  ) %>%
    filter(Count > 0) %>%
    mutate(
      Percent = Count / sum(Count) * 100,
      Label = paste0(Status, "\n", Count, " (", round(Percent, 1), "%)")
    )
  
  if (nrow(pie_data) == 0) return(NULL)
  
  if (dark_mode) {
    bg_color <- "#1e1e1e"
    text_color <- "#e0e0e0"
  } else {
    bg_color <- "#ffffff"
    text_color <- "#333333"
  }
  
  p <- ggplot(pie_data, aes(x = "", y = Count, fill = Color)) +
    geom_bar(stat = "identity", width = 1, color = "white", linewidth = 2) +
    coord_polar("y", start = 0) +
    geom_text(aes(label = Label), 
              position = position_stack(vjust = 0.5),
              color = "white", fontface = "bold", size = 4) +
    scale_fill_identity() +
    labs(title = title) +
    theme_void() +
    theme(
      plot.background = element_rect(fill = bg_color, color = NA),
      plot.title = element_text(size = 14, face = "bold", color = text_color,
                                 hjust = 0.5, margin = margin(b = 10)),
      plot.margin = margin(10, 10, 10, 10)
    )
  
  return(p)
}

# ---- 8. MINI GAUGE GRID ----

#' Tạo grid nhiều gauge nhỏ cho các thông số
#' @param data Data frame với cột Parameter và Percent_of_Limit
#' @param n_cols Số cột
#' @param dark_mode Chế độ tối
#' @return ggplot object (sử dụng facet)
create_gauge_grid <- function(data, n_cols = 4, dark_mode = FALSE) {
  
  if (is.null(data) || nrow(data) == 0) return(NULL)
  
  plot_data <- data %>%
    filter(!is.na(Percent_of_Limit)) %>%
    mutate(
      Percent = pmin(Percent_of_Limit, 150),
      Color = case_when(
        Percent_of_Limit >= 100 ~ "#C62828",
        Percent_of_Limit >= 80 ~ "#F57C00",
        TRUE ~ "#2E7D32"
      ),
      Status = case_when(
        Percent_of_Limit >= 100 ~ "Không đạt",
        Percent_of_Limit >= 80 ~ "Cảnh báo",
        TRUE ~ "Đạt"
      )
    )
  
  if (dark_mode) {
    bg_color <- "#1e1e1e"
    text_color <- "#e0e0e0"
    track_color <- "#444444"
  } else {
    bg_color <- "#ffffff"
    text_color <- "#333333"
    track_color <- "#e0e0e0"
  }
  
  p <- ggplot(plot_data, aes(x = 1, y = 1)) +
    # Background circle
    geom_point(size = 25, color = track_color) +
    # Value circle (scaled)
    geom_point(aes(size = Percent, color = Color)) +
    scale_size_continuous(range = c(5, 20), guide = "none") +
    scale_color_identity() +
    # Text
    geom_text(aes(label = paste0(round(Percent, 0), "%")), 
              color = "white", fontface = "bold", size = 4) +
    geom_text(aes(y = 0.5, label = Status), 
              color = text_color, size = 2.5) +
    facet_wrap(~Parameter, ncol = n_cols) +
    coord_fixed(xlim = c(0.5, 1.5), ylim = c(0.3, 1.5)) +
    theme_void() +
    theme(
      plot.background = element_rect(fill = bg_color, color = NA),
      strip.text = element_text(face = "bold", color = text_color, size = 10),
      panel.spacing = unit(1, "lines"),
      plot.margin = margin(10, 10, 10, 10)
    )
  
  return(p)
}

message("✓ Đã tải visuals.R - Các hàm trực quan hóa (Radar, Gauge, Heatmap)")
