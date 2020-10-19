
def main
  bearers = Bearer.create([
                  { name: 'Bearer1' },
                  { name: 'Bearer2' }])
  Stock.create([
                 { name: 'Stock1_1', bearer_id: 4 },
                 { name: 'Stock2_1', bearer_id: 4 },
                 { name: 'Stock3_1', bearer_id: 5 }])

end

main
