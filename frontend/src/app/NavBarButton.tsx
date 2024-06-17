export default function NavBar({ icon }: { icon: React.ReactNode }) {
  return <div className="flex flex-1 justify-center py-4 text-white hover:bg-white/25">{icon}</div>;
}
