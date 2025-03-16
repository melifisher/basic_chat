import 'package:flutter/material.dart';

class MarkdownFormatter {
  // Procesa texto con markdown simple
  static List<InlineSpan> formatText(String text, TextStyle baseStyle) {
    List<InlineSpan> spans = [];
    
    // Dividir el texto por posibles formatos
    List<String> parts = [];
    
    // Procesamiento de encabezados y formato básico
    RegExp exp = RegExp(r'(#{1,3} [^\n]+)|(\*\*[^*]+\*\*)|(\*[^*]+\*)|(`[^`]+`)|(__[^_]+__)|(_[^_]+_)');
    int lastMatchEnd = 0;
    
    // Procesar el texto y encontrar elementos de markdown
    for (RegExpMatch match in exp.allMatches(text)) {
      // Añadir texto plano antes del formato
      if (match.start > lastMatchEnd) {
        parts.add(text.substring(lastMatchEnd, match.start));
      }
      
      // Añadir el texto con formato
      parts.add(match.group(0)!);
      lastMatchEnd = match.end;
    }
    
    // Añadir el resto del texto después del último formato
    if (lastMatchEnd < text.length) {
      parts.add(text.substring(lastMatchEnd));
    }
    
    // Si no hay formatos, solo devolver el texto original
    if (parts.isEmpty) {
      parts = [text];
    }
    
    // Procesar cada parte y aplicar los estilos correspondientes
    for (String part in parts) {
      // Formato de encabezados
      if (part.startsWith('### ')) {
        spans.add(TextSpan(
          text: part.substring(4),
          style: baseStyle.copyWith(
            fontSize: baseStyle.fontSize! * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ));
        spans.add(const TextSpan(text: '\n'));
      } else if (part.startsWith('## ')) {
        spans.add(TextSpan(
          text: part.substring(3),
          style: baseStyle.copyWith(
            fontSize: baseStyle.fontSize! * 1.5,
            fontWeight: FontWeight.bold,
          ),
        ));
        spans.add(const TextSpan(text: '\n'));
      } else if (part.startsWith('# ')) {
        spans.add(TextSpan(
          text: part.substring(2),
          style: baseStyle.copyWith(
            fontSize: baseStyle.fontSize! * 1.8,
            fontWeight: FontWeight.bold,
          ),
        ));
        spans.add(const TextSpan(text: '\n'));
      }
      // Negrita con **texto**
      else if (part.startsWith('**') && part.endsWith('**')) {
        spans.add(TextSpan(
          text: part.substring(2, part.length - 2),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      }
      // Cursiva con *texto*
      else if (part.startsWith('*') && part.endsWith('*')) {
        spans.add(TextSpan(
          text: part.substring(1, part.length - 1),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      }
      // Código con `texto`
      else if (part.startsWith('`') && part.endsWith('`')) {
        spans.add(TextSpan(
          text: part.substring(1, part.length - 1),
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Colors.grey[200],
          ),
        ));
      }
      // Subrayado con __texto__
      else if (part.startsWith('__') && part.endsWith('__')) {
        spans.add(TextSpan(
          text: part.substring(2, part.length - 2),
          style: baseStyle.copyWith(decoration: TextDecoration.underline),
        ));
      }
      // Cursiva con _texto_
      else if (part.startsWith('_') && part.endsWith('_')) {
        spans.add(TextSpan(
          text: part.substring(1, part.length - 1),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      }
      // Texto sin formato
      else {
        spans.add(TextSpan(text: part, style: baseStyle));
      }
    }
    
    return spans;
  }
}